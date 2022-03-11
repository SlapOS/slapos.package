#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Clean the temporary directory of distribution files for $SOFTWARE_NAME
rm -rf $DISTRIB_TEMPLATES_DIR/tmp/$SOFTWARE_NAME
# Only delete the directory is the file .toclean-stam is present in it. It should only be created
# when the directory is automatically generated so that the cleaning script can reverse the action.
if [ -e $DISTRIB_FILES_DIR/.toclean-stamp ]; then
	rm -rf $DISTRIB_FILES_DIR
fi
