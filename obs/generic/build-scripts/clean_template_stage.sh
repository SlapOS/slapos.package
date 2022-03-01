#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Clean temporary directory for templates
cd $TEMPLATE_DIR
rm -rf tmp/
