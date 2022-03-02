#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
mkdir -p $TARBALL_DIR
# Re-downloading the software release to pack
#cp -r /home/test/other-projects/model/1wip_simplify-fluentbit_my-slapos .
cp -r /home/test/other-projects/new_slapos.package/sid.fluentbit.my-slapos $TARBALL_DIR
#mv 1wip_simplify-fluentbit_my-slapos software_release
mv $TARBALL_DIR/sid.fluentbit.my-slapos $TARBALL_DIR/software_release

cd $INITIAL_DIR
# Peparing the build directories
mkdir -p $RUN_BUILDOUT_DIR/{eggs,extends-cache,download-cache/dist}
