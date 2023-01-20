#!/usr/bin/env python3
import configparser
import subprocess

CONF_PATH = "/etc/opt/slapos/slapos.cfg"

edgepacer_config = {
    'networkcache': {
        'download-from-binary-cache-force-url-list': '''
https://lab.nexedi.com/nexedi/slapos/raw/1.
https://lab.node.vifib.com/nexedi/slapos/raw/1.0.''',
    },
}

with open('/opt/configure-slapos.log', 'w+') as l:

    l.write("[configure-slapos] Configuring slapos...\n")

    config = configparser.ConfigParser()
    config.read(CONF_PATH)
    config['networkcache'].update(edgepacer_config['networkcache'])
    with open(CONF_PATH, 'w+') as f:
        config.write(f)
