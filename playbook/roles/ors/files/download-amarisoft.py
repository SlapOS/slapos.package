#!/usr/bin/env python3
import json, os, shutil, subprocess, sys, tarfile
from pathlib import Path
from datetime import datetime
from slapos.libnetworkcache import NetworkcacheClient
from slapos.libnetworkcache import NetworkcacheFilter

def run(cmd, *args, text=True, **kw):
    return subprocess.run(cmd.split(' '), *args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=text, **kw)

def log(s, *args, **kw):
    print(f'[{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}] {s}', *args, **kw)

amarisoft_dir = Path('/opt/amarisoft')
shacache_cfg  = amarisoft_dir / 'shacache.cfg'
key_dir       = Path('/opt/private-key')
cn            = run('hostname').stdout.strip()
private_key   = key_dir / f'{cn}.key'
public_key    = key_dir / f'{cn}.pub'

if not private_key.is_file() or not public_key.is_file():
    sys.stderr.write(f'Error: {private_key} or {public_key} are not files\n')
    exit(1)

run(f'rm -rf {amarisoft_dir}/download')
os.makedirs(amarisoft_dir / 'download', exist_ok=True)

out = run(f'{amarisoft_dir}/get-amarisoft-info -e')
license_expiration = out.stdout if not out.returncode else '0000-00-00'
out = run(f'{amarisoft_dir}/get-amarisoft-info -v')
current_version, current_timestamp = out.stdout.split('.') if not out.returncode else ('0000-00-00', 0)

log(f'License will expire on {license_expiration}, current version is {current_version}.{current_timestamp}')

shacache_file = open(shacache_cfg, 'r')
nc = NetworkcacheClient(shacache_file)

meta = [
  f'cn=="{cn}"',
  f'version<="{license_expiration}"',
  'timestamp>="0"',
  'version>>"0"',
  'timestamp>>"0"',
]
identifier = 'key-private:amarisoft'
data_list = NetworkcacheFilter(meta)(list(nc.select(identifier)))

if not data_list:
    print("No amarisoft version found")
    exit()

version   = data_list[0]['version']
timestamp = data_list[0]['timestamp']

log(f'Found Amarisoft version: {version}.{timestamp}')

# If found version is newer than current
if version > current_version or (version == current_version and timestamp > current_timestamp):

    log(f'Downloading encrypted key')
    # Download encrypted key
    with open(f'{amarisoft_dir}/download/symmetric_key.bin.enc', 'wb+') as f:
        shutil.copyfileobj(nc.download(data_list[0]['sha512']),
            getattr(f, 'buffer', f)) # Py3
    log(f'Decrypting key')
    # Decrypt key
    run(f'openssl pkeyutl -decrypt -in {amarisoft_dir}/download/symmetric_key.bin.enc -inkey /opt/private-key/{cn}.key -out /opt/private-key/symmetric_key-{version}.key')
    key = run(f'od -An -v -tx1 /opt/private-key/symmetric_key-{version}.key').stdout
    key = key.replace(' ', '').replace('\n', '')

    # Download new amarisoft version
    log(f'Downloading Amarisoft encrypted tar')
    meta = [
      f'version=="{version}"',
      f'timestamp=="{timestamp}"',
    ]
    identifier = 'file-private:amarisoft'
    data_list = NetworkcacheFilter(meta)(list(nc.select(identifier)))
    # Get Nonce
    with open(f'{amarisoft_dir}/download/nonce', 'w+') as f:
        f.write(data_list[0]['nonce'])
    with open(f'{amarisoft_dir}/download/nonce.bin', 'wb+') as f:
        f.write(run(f'openssl base64 -A -in {amarisoft_dir}/download/nonce -d', text=False).stdout)
    iv = run(f'openssl base64 -A -in {amarisoft_dir}/download/nonce -d', text=False).stdout
    iv = run(f'od -An -v -tx1 {amarisoft_dir}/download/nonce.bin').stdout
    iv = iv.replace(' ', '').replace('\n', '')
    # Download encrypted amarisoft tar
    with open(f'{amarisoft_dir}/download/amarisoft.tar.gz.enc', 'wb+') as f:
        shutil.copyfileobj(nc.download(data_list[0]['sha512']),
            getattr(f, 'buffer', f)) # Py3
    # Decrypt amarisoft tar
    log(f'Decrypting Amarisoft encrypted tar')
    run(f'openssl enc -d -chacha20 -K {key} -iv {iv} -nosalt -in {amarisoft_dir}/download/amarisoft.tar.gz.enc -out {amarisoft_dir}/amarisoft.tar.gz')

    # Download fpga
    log(f'Downloading FPGA encrypted bin')
    meta = [
      f'version=="{version}"',
      f'timestamp=="{timestamp}"',
    ]
    identifier = 'file-private:fpga'
    data_list = NetworkcacheFilter(meta)(list(nc.select(identifier)))
    fpga_version = data_list[0]['fpga_version']
    # Download encrypted FPGA bin
    with open(f'{amarisoft_dir}/download/fpga.bin.enc', 'wb+') as f:
        shutil.copyfileobj(nc.download(data_list[0]['sha512']),
            getattr(f, 'buffer', f)) # Py3
    # Decrypt FPGA bin
    log(f'Decrypting FPGA encrypted bin')
    run(f'openssl enc -d -chacha20 -K {key} -iv {iv} -nosalt -in {amarisoft_dir}/download/fpga.bin.enc -out {amarisoft_dir}/fpga-{fpga_version}.{version}.{timestamp}.bin')

    os.makedirs(amarisoft_dir / version, exist_ok=True)
    os.makedirs(amarisoft_dir / f'_{version}', exist_ok=True)

    log(f'Extracting Amarisoft tar files')
    with tarfile.open(f'{amarisoft_dir}/amarisoft.tar.gz') as f:
        f.extractall(amarisoft_dir)
    with tarfile.open(f'{amarisoft_dir}/{version}/lteenb-linux-{version}.tar.gz') as f:
        f.extractall(f'{amarisoft_dir}/_{version}')
    with tarfile.open(f'{amarisoft_dir}/{version}/ltemme-linux-{version}.tar.gz') as f:
        f.extractall(f'{amarisoft_dir}/_{version}')
    with tarfile.open(f'{amarisoft_dir}/{version}/trx_sdr-linux-{version}.tar.gz') as f:
        f.extractall(f'{amarisoft_dir}/_{version}')

    log(f'Making Amarisoft symlinks')
    os.symlink(f'lteenb-linux-{version}', f'{amarisoft_dir}/_{version}/enb')
    os.symlink(f'ltemme-linux-{version}', f'{amarisoft_dir}/_{version}/mme')
    os.symlink(f'trx_sdr-linux-{version}', f'{amarisoft_dir}/_{version}/trx_sdr')

    log(f'Copying Amarisoft libraries')
    run(f'cp {amarisoft_dir}/_{version}/trx_sdr/*.so* {amarisoft_dir}/_{version}/enb/')
    run(f'cp {amarisoft_dir}/{version}/libs/*.so* {amarisoft_dir}/_{version}/mme/')
    run(f'cp {amarisoft_dir}/{version}/libs/linux/*.so* {amarisoft_dir}/_{version}/mme/')
    run(f'cp {amarisoft_dir}/{version}/libs/*.so* {amarisoft_dir}/_{version}/enb/')
    run(f'cp {amarisoft_dir}/{version}/libs/linux/*.so* {amarisoft_dir}/_{version}/enb/')
    run(f'mv {amarisoft_dir}/_{version} {amarisoft_dir}/v{version}.{timestamp}')
    run(f'rm -rf {amarisoft_dir}/{version}')

    log(f'New Amarisoft version has been installed in {amarisoft_dir}/v{version}.{timestamp}')
    log(f'FPGA binary has been installed in {amarisoft_dir}/fpga-{fpga_version}.{version}.{timestamp}.bin')
else:
    log('Amarisoft version from shacache is not newer than current version')
