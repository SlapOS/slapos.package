#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Prepare the templates in $TEMPLATE_DIR/tmp/
mkdir -p $TEMPLATE_DIR/tmp/
sed $ALL_REGEX $TEMPLATE_DIR/buildout_with_gcc.cfg.in > 	$TEMPLATE_DIR/tmp/buildout_with_gcc.cfg
sed $ALL_REGEX $TEMPLATE_DIR/buildout_without_gcc.cfg.in > 	$TEMPLATE_DIR/tmp/buildout_without_gcc.cfg
sed $ALL_REGEX $TEMPLATE_DIR/Makefile.in > 			$TEMPLATE_DIR/tmp/Makefile
