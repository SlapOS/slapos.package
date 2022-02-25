#!/bin/bash
set -e

source configuration_information.sh

cd $INITIAL_DIR
# Remove the bootstrap script and associated files
if [[ -d $PARTS_DIR ]]; then
	cd $PARTS_DIR
	rm -f bootstrap.py # LEGACY
	rm -f bootstrap-buildout.py*
	rm -f buildout.cfg
fi

cd $INITIAL_DIR
# Clean the material created by the bootstrap script
if [[ -d $PARTS_DIR ]]; then
	cd $PARTS_DIR
	rm -rf bin/
	rm -rf eggs/
fi
