#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Clean temporary directory for templates
rm -rf $TEMPLATE_DIR/tmp/
