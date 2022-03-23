#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Download the bootstrap script
mkdir -p $RUN_BUILDOUT_DIR
cd $RUN_BUILDOUT_DIR
wget https://bootstrap.pypa.io/bootstrap-buildout.py

cd $INITIAL_DIR
# Create a build/bin/buildout (bootstraping) and run it (actual compilation).
# Note: it creates a lot of things in build/eggs/ and uses software_release/ at some point
mkdir -p $RUN_BUILDOUT_DIR
cd $RUN_BUILDOUT_DIR
# should be with gcc here and without in OBS
cp $COMPILATION_TEMPLATES_DIR/tmp/$SOFTWARE_NAME/local_buildout.cfg buildout.cfg
## next line explained
# 1st cmd: bootstrap buildout (creates bin/buildout)
# 2nd cmd: backup bin/buildout (to be restored for OBS)
# 3rd cmd: run buildout (which apparently modifies itself)
(python2.7 -S bootstrap-buildout.py --buildout-version 2.7.1+slapos016 --setuptools-version 44.1.1 --setuptools-to-dir eggs -f http://www.nexedi.org/static/packages/source/slapos.buildout/ && cp bin/buildout bin/backup.buildout && ./bin/buildout -v)
#cp $COMPILATION_TEMPLATES_DIR/tmp/buildout_with_gcc.cfg buildout.cfg

cd $INITIAL_DIR
# Fix the go/ directory.

# For some reason the user does not have the "write" permission on some directories of go/. As it is
# needed on a directory to delete a file in it, the if block adds the permissions to every
# directories in go/.
# This is performed before copying the directory tree elsewhere so that every copy is fixed.
# It also allows the cleaning script to delete the result of the current script.
if [ -d $RUN_BUILDOUT_DIR/go ]; then
        find $RUN_BUILDOUT_DIR/go -name "*" -type d -exec chmod u+xw {} +
fi

cd $INITIAL_DIR
# Backup $TARBALL_DIR for debugging or other purpose

# add "backup." before the directory name pointed to by $TARBALL_DIR
BACKUP_DIR=$TARBALL_DIR/../backup.$SOFTWARE_AND_VERSION
BACKUP_DIR=`realpath -m $BACKUP_DIR`
# Delete the potential previous backup and backup the newly created build tree instead.
rm -rf $BACKUP_DIR
cp -r $TARBALL_DIR $BACKUP_DIR
