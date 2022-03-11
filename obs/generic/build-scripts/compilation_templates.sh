#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Prepare the templates in $COMPILATION_TEMPLATES_DIR/tmp/
mkdir -p $COMPILATION_TEMPLATES_DIR/tmp/
sed $ALL_REGEX $COMPILATION_TEMPLATES_DIR/buildout_with_gcc.cfg.in > 	$COMPILATION_TEMPLATES_DIR/tmp/buildout_with_gcc.cfg
sed $ALL_REGEX $COMPILATION_TEMPLATES_DIR/buildout_without_gcc.cfg.in > 	$COMPILATION_TEMPLATES_DIR/tmp/buildout_without_gcc.cfg
sed $ALL_REGEX $COMPILATION_TEMPLATES_DIR/Makefile.in > 			$COMPILATION_TEMPLATES_DIR/tmp/Makefile
