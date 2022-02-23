#!/bin/bash
set -e

source configuration_information.sh

cd $INITIAL_DIR
# Clean the software release to pack
cd tarball/$SOFTWARE/
rm -rf slapos slapos_repository # LEGACY
rm -rf software_release

cd $INITIAL_DIR
# Clean the build tree
rm -rf $PARTS_DIR/{eggs,extends-cache,download-cache,tmp-networkcached}
