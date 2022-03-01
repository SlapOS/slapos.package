#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
mkdir -p tarballs/$SOFTWARE/
# Re-downloading the software release to pack
cd tarballs/$SOFTWARE/
git clone https://lab.nexedi.com/Francois/slapos
mv slapos software_release
cd software_release
git checkout fluent-bit

cd $INITIAL_DIR
# Peparing the build directories
mkdir -p $RUN_BUILDOUT_DIR/{eggs,extends-cache,download-cache/dist}
