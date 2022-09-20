#!/usr/bin/env python3
import configparser
import subprocess

CONF_PATH = "/etc/opt/slapos/slapos.cfg"

ors_config = {
    'slapformat': {
        'create_tun': 'True',
        'create_tap': 'False',
        'partition_amount': '20',
    },
    'networkcache': {
        'download-from-binary-cache-force-url-list': '''
https://lab.nexedi.com/nexedi/slapos/raw/1.
https://lab.node.vifib.com/nexedi/slapos/raw/1.0.''',
    },
}

config = configparser.ConfigParser()
config.read(CONF_PATH)

def is_slapformat_valid():
    for k in ors_config['slapformat']:
        if ors_config['slapformat'][k] != \
           config.setdefault('slapformat', {}).setdefault(k, ''):
            return False
    return True
slapformat_valid = is_slapformat_valid()

config['slapformat'].update(ors_config['slapformat'])
config['networkcache'].update(ors_config['networkcache'])
with open(CONF_PATH, 'w+') as f:
    config.write(f)

if not slapformat_valid:
    # Delete routes
    s = subprocess.run(['ip', 'route'], check=True, capture_output=True)
    for r in s.stdout.decode().split('\n'):
        if "slaptun" in r:
            l = r.split(' ')
            subprocess.run(['ip', 'route', 'del',] + l[:l.index('dev') + 2], check=True)
    subprocess.run(['rm', '-f', '/opt/slapos/slapos.xml'], check=True)
    subprocess.run(['slapos', 'node', 'format', '--now'], check=True, capture_output=True)
