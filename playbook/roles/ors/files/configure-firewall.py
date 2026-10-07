#!/usr/bin/env python3
import os, subprocess, time

def run(cmd, *args, **kw):
    return subprocess.run(cmd.split(' '), *args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, **kw)

# Enable ipv4 and ipv6 forwarding for core network
with open('/proc/sys/net/ipv4/conf/all/forwarding', 'w+') as f:
    f.write("1")
with open('/proc/sys/net/ipv6/conf/all/forwarding', 'w+') as f:
    f.write("1")

# Set correct iptables rules
os.makedirs('/etc/iptables', exist_ok=True)
interface_list = []
for interface in run('find /sys/class/net -type l -printf %f\\n').stdout.strip().split('\n'):
    if not os.path.realpath(f'/sys/class/net/{interface}').startswith('/sys/devices/virtual'):
        interface_list.append(interface)
interface_list = sorted(interface_list)
conf_v4     = "/etc/iptables/rules.v4"
tmp_conf_v4 = f"/tmp/rules.v4.{time.time()}"
conf_v6     = "/etc/iptables/rules.v6"
tmp_conf_v6 = f"/tmp/rules.v6.{time.time()}"

## Write target IPv4 rules
with open(tmp_conf_v4, 'w+') as f:
    f.write("""*nat
:PREROUTING ACCEPT
:INPUT ACCEPT
:OUTPUT ACCEPT
:POSTROUTING ACCEPT
""")

for interface in interface_list:
    with open(tmp_conf_v4, 'a') as f:
        f.write(f"-A POSTROUTING -o {interface} -j MASQUERADE\n")
with open(tmp_conf_v4, 'a') as f:
    f.write("""COMMIT
*filter
:INPUT ACCEPT
:FORWARD ACCEPT
:OUTPUT ACCEPT
COMMIT
""")

## Write target IPv6 rules
with open(tmp_conf_v6, 'w+') as f:
    f.write("""*nat
:PREROUTING ACCEPT
:INPUT ACCEPT
:OUTPUT ACCEPT
:POSTROUTING ACCEPT
COMMIT
*filter
:INPUT ACCEPT
:FORWARD ACCEPT
:OUTPUT ACCEPT
COMMIT
""")

## Reconfigure iptables if current rules doens't match target rules
run(f'touch {conf_v4} {conf_v6}')
if run(f'diff {tmp_conf_v4} {conf_v4}').returncode:
    run(f'cp {tmp_conf_v4} {conf_v4}')
    run(f'iptables-restore {conf_v4}')

run(f'touch {conf_v6} {conf_v6}')
if run(f'diff {tmp_conf_v6} {conf_v6}').returncode:
    run(f'cp {tmp_conf_v6} {conf_v6}')
    run(f'iptables-restore {conf_v6}')

print(f'rm -f {tmp_conf_v4} {tmp_conf_v6}')
#run(f'rm -f {tmp_conf_v4} {tmp_conf_v6}')
