#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
rm -rf $TARBALL_DIR

exit # TODO: separate the tree building from the software release retrieving

cd $INITIAL_DIR
# Clean the software release to pack
rm -rf $TARBALL_DIR/software_release

cd $INITIAL_DIR
# Clean the build tree
rm -rf $RUN_BUILDOUT_DIR/{eggs,extends-cache,download-cache}
