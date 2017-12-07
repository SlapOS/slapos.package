erp5-standalone RPMs
====================

CentoOS 7.4 preparation
-----------------------

Do all as root.

Install rpmbuild with:

``# yum install rpm-build``

Prepare directories:

``# mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SRPMS}``

Setup rpm:

``# echo '%_topdir %(echo $HOME)/rpmbuild' > ~/.rpmmacros``

Link this directory to ~/rpmbuild/SPECS:

``# ln -s `pwd` ~/rpmbuild/SPECS``

Building
--------

Compile ERP5 with erp5-standalone script.

Go to ``~/rpmbuild/SPECS``.

Build all RPMs with:

``# rpmbuild -bb *spec``

You'll find RPMs in ``~/rpmbuild/RPMS/x86_64``

Usage - instruction to user installing with RPMs
------------------------------------------------

Required machine is CentOS 7.4 with at least Netinstall.

The RPMs shall be downloaded and to one directory, from which all below commands
will be run.

Procedure, all with `root` user:

 * uninstall firewalld: `yum remove -y firewalld`
 * install slapos.node: `yum install -y slapos.node*rpm`
 * add local IPv6: `ip -6 addr add 2001::1/64 dev lo`
 * create directories: `mkdir -p /opt/slapgrid /srv/slapgrid`
 * configure the node: `slapos configure local`
 * kill supervisor: ``kill `cat /srv/slapgrid/var/run/supervisord.pid ```
 * wait a bit: `sleep 5`
 * boot the supervisor: `slapos node instance --now --verbose`
 * wait a bit: `sleep 15`
 * format the machine: `slapos node format --now --alter_user=True`
 * install ERP5 code: `yum install -y erp5*rpm`

Now by using playbook the user can check if all is working:

``ansible-playbook /opt/slapos.playbook/erp5-standalone.yml``

The expected result is:

```
TASK [standalone-shared : Expose ERP5] ***************************************************************
ok: [<machine_public_ipv4>] => {
    "msg": [
        "Build successful, connect to:", 
        "  https://<machine_public_ipv4>", 
        "", 
        " with", 
        "  username: zope  password: uqagckyo"
    ]
}
```

where <machine_public_ipv4> is replaced with public IPv4 of the machine.