#!/usr/bin/env python3
import configparser
import subprocess

CONF_PATH = "/etc/opt/slapos/slapos.cfg"

ors_config = {
    'slapformat': {
        'create_tun': 'True',
        'partition_amount': '20',
        'ipv6_prefixshift': '7',
    },
    'networkcache': {
        'download-from-binary-cache-force-url-list': '''
https://lab.nexedi.com/nexedi/slapos/raw/1.
https://lab.node.vifib.com/nexedi/slapos/raw/1.0.''',
    },
}

with open('/opt/upgrader/configure-slapos.log', 'w+') as l:

    l.write("[configure-slapos] Configuring slapos...\n")

    config = configparser.ConfigParser()
    config.read(CONF_PATH)

    # Don't create tun in UE mode
    if "lte-ue" in subprocess.run(['slapos', 'node'], check=False, capture_output=True, text=True).stdout:
        print("In UE mode: no TUN interfaces")
        ors_config['slapformat']['create_tun'] = 'False'
    else:
        print("In Base Station mode: with TUN interfaces")

    def is_slapformat_valid():
        for k in ors_config['slapformat']:
            if ors_config['slapformat'][k] != \
               config.setdefault('slapformat', {}).setdefault(k, ''):
                l.write("[configure-slapos] {} not valid ( {} != {} )\n".format(k, ors_config['slapformat'][k], config.setdefault('slapformat', {}).setdefault(k, '')))
                return False
        return True
    slapformat_valid = is_slapformat_valid()

    config['slapformat'].update(ors_config['slapformat'])
    config['networkcache'].update(ors_config['networkcache'])
    with open(CONF_PATH, 'w+') as f:
        config.write(f)


    if not slapformat_valid:
        l.write("[configure-slapos] slapos.cfg not valid\n")
        # Delete slaptun devices
        for i in range(0,19):
            subprocess.run(['ip', 'link', 'delete', 'slaptun{}'.format(i)])
        subprocess.run(['rm', '-f', '/opt/slapos/slapos.xml'], check=True)
        subprocess.run(['slapos', 'node', 'format', '--now'], check=True, capture_output=True)
