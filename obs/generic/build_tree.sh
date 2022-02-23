#!/bin/bash
set -e

source configuration_information.sh

cd $INITIAL_DIR
mkdir -p tarball/$SOFTWARE/
# Re-downloading the software release to pack
cd tarball/$SOFTWARE/
git clone https://lab.nexedi.com/Francois/slapos
mv slapos software_release
cd software_release
git checkout fluent-bit

cd $INITIAL_DIR
# Peparing the build directories
mkdir -p $PARTS_DIR/{eggs,extends-cache,download-cache/dist,tmp-networkcached/eggs}
