#!/bin/bash
set -e

source build-scripts/00env.sh

cd "$INITIAL_DIR"
### Download the bootstrap script
mkdir -p "$RUN_BUILDOUT_DIR"
cd "$RUN_BUILDOUT_DIR"
wget https://bootstrap.pypa.io/bootstrap-buildout.py

cd "$INITIAL_DIR"
### Create a $RUN_BUILDOUT_DIR/bin/buildout (bootstraping) and run it (actual compilation).
# Note: it creates a lot of things in $RUN_BUILDOUT_DIR/eggs/ and uses software_release/ at some point
mkdir -p "$RUN_BUILDOUT_DIR"
cd "$RUN_BUILDOUT_DIR"
# should be with gcc here and without in OBS
cp "$COMPILATION_TEMPLATES_DIR"/tmp/"$SOFTWARE_NAME"/local_buildout.cfg buildout.cfg
## next line explained
# 1st cmd: bootstrap buildout (creates bin/buildout)
# 2nd cmd: backup $RUN_BUILDOUT_DIR/bin/buildout (to be restored for OBS)
# 3rd cmd: run buildout (which modifies itself via rebootstrapping when compiling python)
(python2.7 -S bootstrap-buildout.py --buildout-version 2.7.1+slapos016 --setuptools-version 44.1.1 --setuptools-to-dir eggs -f http://www.nexedi.org/static/packages/source/slapos.buildout/ && cp bin/buildout bin/backup.buildout && ./bin/buildout -v)
