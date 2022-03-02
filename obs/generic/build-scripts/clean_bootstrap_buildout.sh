#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Remove the bootstrap script and associated files
rm -f $RUN_BUILDOUT_DIR/{bootstrap.py,bootstrap-buildout.py,buildout.cfg}

cd $INITIAL_DIR
# Clean the material created by the bootstrap script
rm -rf $RUN_BUILDOUT_DIR/{bin/,egg/}
