#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
rm -rf tarballs/$SOFTWARE/

exit # TODO: separate the tree building from the software release retrieving

cd $INITIAL_DIR
# Clean the software release to pack
if [[ -d tarballs/$SOFTWARE/ ]]; then
	cd tarballs/$SOFTWARE/
	rm -rf software_release
else echo tarballs/$SOFTWARE/ does not exist.

cd $INITIAL_DIR
# Clean the build tree
rm -rf $RUN_BUILDOUT_DIR/{eggs,extends-cache,download-cache}
