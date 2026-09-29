#!/usr/bin/env python3

import os, subprocess

def run(cmd, *args, **kw):
    return subprocess.run(cmd.split(' '), *args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, **kw)

re6st_conf = "/etc/re6stnet/re6stnet.conf"

interface_list = []
for interface in run('find /sys/class/net -type l -printf %f\\n').stdout.strip().split('\n'):
    if not os.path.realpath(f'/sys/class/net/{interface}').startswith('/sys/devices/virtual'):
        interface_list.append(interface)
interface_list = sorted(interface_list)

new_re6st_conf = []
conf_interface_set = set()
with open(re6st_conf, 'r') as f:
    for l in f:
        interface = [interface for interface in interface_list if l.startswith(f'interface {interface}')]
        if interface:
            conf_interface_set.add(*interface)
        else:
            new_re6st_conf.append(l)

if len(conf_interface_set) != len(interface_list):
    for interface in interface_list:
        new_re6st_conf.append(f'interface {interface}\n')
    with open(re6st_conf, 'w+') as f:
        f.write(''.join(new_re6st_conf))
        run('systemctl restart re6stnet')
