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

Provide all RPMs with `install.sh` in one directory (eg. tarball).

Ask user to run `install.sh` as `root`.

More instructions will be provided after running this script.