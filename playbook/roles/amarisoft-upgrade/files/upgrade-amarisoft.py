#!/usr/bin/env python3
from hashlib import md5
from slapos.libnetworkcache import NetworkcacheClient
import base64, json, hashlib, os, re, socket, sys

lte_path = '/opt/amarisoft/download'
amarisoft_binaries_key = 'file-private:amarisoft'
amarisoft_binaries_key_key = 'key-private:amarisoft'

def get_lte_version():
  try:
    lte_version = sorted(filter(lambda x: re.match(r"v[0-9]{4}-[0-9]{2}-[0-9]{2}", x), os.listdir('/opt/amarisoft')))[-1][1:]
  except FileNotFoundError:
    lte_version = 'LTEVERSION'
  lte_expiration = "Unknown"
  amarisoft_dir = '/opt/amarisoft/.amarisoft'
  try:
    for filename in os.listdir(amarisoft_dir):
      if filename.endswith('.key'):
        with open(os.path.join(amarisoft_dir, filename), 'r') as f:
          f.seek(260)
          for l in f:
            if l.startswith('version='):
              lte_expiration = l.split('=')[1].strip()
  except FileNotFoundError:
    pass
  return lte_expiration, lte_version

def download_key(shacache, version):
  key = amarisoft_binaries_key_key
  response = shacache.select(hashlib.md5(key.encode()).hexdigest(), {}, [])
  cn = socket.gethostname()
  
  for entry in response:
    if entry['version'] == version and entry['cn'] == cn:
      print("Downloading keys for version {} and cn {}".format(version, cn))
      response = entry['encrypted-symkey']
      with open(os.path.join(lte_path, 'symmetric_key-{}.bin.enc'.format(version)), 'bw+') as f:
        f.write(base64.b64decode(response.encode()))
      return True
  return False

def upgrade(shacache, lte_expiration, lte_version):
  key = amarisoft_binaries_key
  response = shacache.select(md5(key.encode()).hexdigest(), {}, [])

  entry_list = sorted(
	[entry for entry in response],
	key=lambda entry: entry['version'],
	reverse=True)

  for entry in entry_list:
    version = entry['version']
    if version <= lte_version:
      print("Current amarisoft version ({}) is up to date".format(lte_version))
      break
    if version > lte_expiration:
      continue
    print("Downloading version {}".format(version))
    response = shacache._request('cache', entry['sha512'])
    with open(os.path.join(lte_path, 'amarisoft.{}.tar.gz.enc'.format(version)), 'bw+') as f:
      f.write(response.response.read())
    download_key(shacache, version)
    return True
  print("License expiration date ({}) does not allow to download any new amarisoft versions".format(lte_expiration))
  return False

def main():

  slapos_config = '/etc/opt/slapos/slapos.cfg'
  shacache = NetworkcacheClient(open(slapos_config, 'r'))

  return not upgrade(shacache, *get_lte_version())

if __name__ == '__main__':
  sys.exit(main())
