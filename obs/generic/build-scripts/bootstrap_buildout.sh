#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Download the bootstrap script
cd $RUN_BUILDOUT_DIR
wget https://bootstrap.pypa.io/bootstrap-buildout.py

cd $INITIAL_DIR
# Create a build/bin/buildout (bootstraping) and run it (actual compilation).
# Note: it creates a lot of things in build/eggs/ and uses software_release/ at some point
cd $RUN_BUILDOUT_DIR
# should be with gcc here and without in OBS
cp $TEMPLATE_DIR/tmp/buildout_without_gcc.cfg buildout.cfg
(python2.7 -S bootstrap-buildout.py --buildout-version 2.7.1+slapos016 --setuptools-version 44.1.1 --setuptools-to-dir eggs -f http://www.nexedi.org/static/packages/source/slapos.buildout/ && ./bin/buildout -v)
#cp $TEMPLATE_DIR/tmp/buildout_with_gcc.cfg buildout.cfg
