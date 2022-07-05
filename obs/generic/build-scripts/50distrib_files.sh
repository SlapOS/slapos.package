#!/bin/bash
set -e

source build-scripts/00env.sh

cd "$INITIAL_DIR"
# Prepare the templates in $DISTRIB_TEMPLATES_DIR/tmp/
TMP_TARGET="$DISTRIB_TEMPLATES_DIR"/tmp/"$SOFTWARE_NAME"/
mkdir -p "$TMP_TARGET"
sed "$ALL_REGEX" "$DISTRIB_TEMPLATES_DIR"/default.dsc.in >			"$TMP_TARGET"/"$SOFTWARE_AND_VERSION".dsc
# debian directory
mkdir -p "$TMP_TARGET"/debian/
sed "$ALL_REGEX" "$DISTRIB_TEMPLATES_DIR"/debian_default/changelog.in >	"$TMP_TARGET"/debian/changelog
sed "$ALL_REGEX" "$DISTRIB_TEMPLATES_DIR"/debian_default/control.in >	"$TMP_TARGET"/debian/control
sed "$ALL_REGEX" "$DISTRIB_TEMPLATES_DIR"/debian_default/dirs.in >		"$TMP_TARGET"/debian/dirs
cp -r "$DISTRIB_TEMPLATES_DIR"/debian_default/{compat,copyright,rules,source} "$TMP_TARGET"/debian/

# TODO: do it with "find" instead?
#find "$DISTRIB_TEMPLATES_DIR"/debian_defaults/ -type f -name * -exec sed "$ALL_REGEX" {} + > "$TMP_TARGET"/debian/

# If a directory for the current software does not already exist in distrubion-specifics:
# create it and copy the product of the templates in it,
# otherwise do nothing.
# The files created form the templates are still available in $TMP_TARGET
if [ ! -d "$DISTRIB_FILES_DIR" ]; then
	mkdir -p "$DISTRIB_FILES_DIR"
	cp -r "$TMP_TARGET"/* "$DISTRIB_FILES_DIR"/
	# A file is created so that the cleaning script can reverse the action of the current script.
	echo -e "This file's only purpose is to tell the cleaning script to delete this directory.\nThere should not be such file in a manually crafted directory.\n" >> "$DISTRIB_FILES_DIR"/.toclean-stamp
fi
