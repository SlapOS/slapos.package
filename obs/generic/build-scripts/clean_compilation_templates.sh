#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Clean temporary directory for templates
rm -rf $COMPILATION_TEMPLATES_DIR/tmp/$SOFTWARE_NAME
