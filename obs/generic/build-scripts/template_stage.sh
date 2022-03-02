#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Prepare the templates in $TEMPLATE_DIR/tmp/
cd $TEMPLATE_DIR
mkdir -p tmp/
sed $ALL_REGEX buildout_with_gcc.cfg.in > tmp/buildout_with_gcc.cfg
sed $ALL_REGEX buildout_without_gcc.cfg.in > tmp/buildout_without_gcc.cfg
sed $ALL_REGEX Makefile.in > tmp/Makefile
