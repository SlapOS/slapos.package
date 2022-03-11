#!/bin/bash
set -e

source build-scripts/configuration_information.sh

cd $INITIAL_DIR
# Prepare the templates in $DISTRIB_TEMPLATES_DIR/tmp/
mkdir -p $DISTRIB_TEMPLATES_DIR/tmp/debian/
sed $ALL_REGEX $DISTRIB_TEMPLATES_DIR/default.dsc.in >			$DISTRIB_TEMPLATES_DIR/tmp/$SOFTWARE_AND_VERSION.dsc
# debian directory
sed $ALL_REGEX $DISTRIB_TEMPLATES_DIR/debian_default/changelog.in >	$DISTRIB_TEMPLATES_DIR/tmp/debian/changelog
sed $ALL_REGEX $DISTRIB_TEMPLATES_DIR/debian_default/control.in >	$DISTRIB_TEMPLATES_DIR/tmp/debian/control
sed $ALL_REGEX $DISTRIB_TEMPLATES_DIR/debian_default/dirs.in >		$DISTRIB_TEMPLATES_DIR/tmp/debian/dirs
cp -r $DISTRIB_TEMPLATES_DIR/debian_default/{compat,copyright,rules,source} $DISTRIB_TEMPLATES_DIR/tmp/debian/

# TODO: do it with "find" instead?
#find $DISTRIB_TEMPLATES_DIR/debian_defaults/ -type f -name * -exec sed $ALL_REGEX {} + > $DISTRIB_TEMPLATES_DIR/tmp/debian/

mkdir -p $INITIAL_DIR/distribution-specifics/$SOFTWARE_NAME/
cp -r $DISTRIB_TEMPLATES_DIR/tmp/* $DISTRIB_FILES_DIR/
