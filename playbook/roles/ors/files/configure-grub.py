#!/usr/bin/env python3
import os, subprocess

def run(cmd, *args, **kw):
    return subprocess.run(cmd.split(' '), *args, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, **kw)

conf   = "/etc/default/grub"
backup = "/tmp/default.grub"

run(f'cp {conf} {backup}')
grub_cfg_write = []
with open('/etc/default/grub', 'r') as f:
    for l in f:
        if l.startswith('GRUB_CMDLINE_LINUX_DEFAULT'):
            cmdline = l.split('"')[1].split('"')[0].split(' ')
            cmdline = filter(lambda cmd: not cmd.startswith('idle='), cmdline)
            cmdline = filter(lambda cmd: not cmd.startswith('maxcpus='), cmdline)
            cmdline = filter(lambda cmd: not cmd.startswith('nosmt='), cmdline)
            cmdline = list(cmdline) + 'idle=halt nosmt=force'.split(' ')
            grub_cfg_write.append(f'GRUB_CMDLINE_LINUX_DEFAULT="{" ".join(cmdline)}"\n')
        else:
            grub_cfg_write.append(l)
with open('/etc/default/grub', 'w') as f:
    f.write(''.join(grub_cfg_write))

with open('/proc/cmdline', 'r') as f:
    proc_cmdline=f.read()

if 'idle=halt' not in proc_cmdline or 'nosmt=force' not in proc_cmdline:
    if run('update-grub').returncode:
        run(f'cp {backup} {conf}') # Revert if update grub failed
run(f'rm -f {backup}')
