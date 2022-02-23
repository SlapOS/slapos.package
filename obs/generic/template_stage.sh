#!/bin/bash
set -e

source configuration_information.sh

cd $INITIAL_DIR
# Prepare the templates in $TEMPLATE_DIR/tmp/
cd $TEMPLATE_DIR
mkdir -p tmp/
sed $VERSION_REGEX";"$DIR_REGEX networkcached.cfg.in > tmp/networkcached.cfg
sed $VERSION_REGEX";"$DIR_REGEX buildout_with_gcc.cfg.in > tmp/buildout_with_gcc.cfg
sed $VERSION_REGEX";"$DIR_REGEX buildout_without_gcc.cfg.in > tmp/buildout_without_gcc.cfg
