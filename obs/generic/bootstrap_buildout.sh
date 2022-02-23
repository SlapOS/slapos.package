#!/bin/bash
set -e

source configuration_information.sh

cd $INITIAL_DIR
# Download the bootstrap script
cd $PARTS_DIR/tmp-networkcached
wget https://bootstrap.pypa.io/bootstrap-buildout.py

cd $INITIAL_DIR
# Create a build/tmp-networkcached/bin/buildout
# Also create a lot of things in build/tmp-networkcached/eggs/
# it uses software_release/ at some point
cd $PARTS_DIR/tmp-networkcached
cp $TEMPLATE_DIR/tmp/networkcached.cfg buildout.cfg
(python2.7 -S bootstrap-buildout.py --buildout-version 2.7.1+slapos016 --setuptools-version 44.1.1 --setuptools-to-dir eggs -f http://www.nexedi.org/static/packages/source/slapos.buildout/ && ./bin/buildout -v)
