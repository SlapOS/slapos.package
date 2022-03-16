#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# For some reason the user does not have the "write" permission on some directories of go/. As it is
# needed on a directory to delete a file in it, the if block add the permissions to every
# directories in go/.
if [ -d $RUN_BUILDOUT_DIR/go ]; then
	find $RUN_BUILDOUT_DIR/go -name "*" -type d -exec chmod u+xw {} +
fi
rm -rf $TARBALL_DIR

exit # TODO: separate the tree building from the software release retrieving

cd $INITIAL_DIR
# Clean the software release to pack
rm -rf $TARBALL_DIR/software_release

cd $INITIAL_DIR
# Clean the build tree
rm -rf $RUN_BUILDOUT_DIR/{eggs,extends-cache,download-cache}
