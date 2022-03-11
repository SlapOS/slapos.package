#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Prepare the templates in $COMPILATION_TEMPLATES_DIR/tmp/$SOFTWARE_NAME
mkdir -p $COMPILATION_TEMPLATES_DIR/tmp/$SOFTWARE_NAME

# if a custom directory exist for compilation templates, choose it
# otherwise, default to .../_generic
ACTUAL_TEMPLATES_DIR=$COMPILATION_TEMPLATES_DIR/$SOFTWARE_NAME
if [ ! -d $ACTUAL_TEMPLATES_DIR ]; then
	ACTUAL_TEMPLATES_DIR=$COMPILATION_TEMPLATES_DIR/_generic
fi

sed $ALL_REGEX $ACTUAL_TEMPLATES_DIR/local_buildout.cfg.in > 	$COMPILATION_TEMPLATES_DIR/tmp/$SOFTWARE_NAME/local_buildout.cfg
sed $ALL_REGEX $ACTUAL_TEMPLATES_DIR/Makefile.in > 			$COMPILATION_TEMPLATES_DIR/tmp/$SOFTWARE_NAME/Makefile
