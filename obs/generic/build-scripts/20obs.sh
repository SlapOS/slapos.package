#!/bin/bash
set -e

source build-scripts/00env.sh

cd "$INITIAL_DIR"
### Fix the go/ directory.

cd "$INITIAL_DIR"
### Clean the temporary directory of distribution files for "$SOFTWARE_NAME"
rm -rf "$DISTRIB_TEMPLATES_DIR"/tmp/"$SOFTWARE_NAME"
# Only delete the directory if the file .toclean-stamp is present in it. It should only be created
# when the directory is automatically generated so that the cleaning script can reverse the action.
if [ -e "$DISTRIB_FILES_DIR"/.toclean-stamp ]; then
	rm -rf "$DISTRIB_FILES_DIR"
fi

cd "$INITIAL_DIR"
### Prepare the templates in $DISTRIB_TEMPLATES_DIR/tmp/
TMP_TARGET="$DISTRIB_TEMPLATES_DIR"/tmp/"$SOFTWARE_NAME"/
mkdir -p "$TMP_TARGET"
sed "$ALL_REGEX" "$DISTRIB_TEMPLATES_DIR"/default.dsc.in >              "$TMP_TARGET"/"$SOFTWARE_AND_VERSION".dsc
# debian directory
mkdir -p "$TMP_TARGET"/debian/
sed "$ALL_REGEX" "$DISTRIB_TEMPLATES_DIR"/debian_default/changelog.in > "$TMP_TARGET"/debian/changelog
sed "$ALL_REGEX" "$DISTRIB_TEMPLATES_DIR"/debian_default/control.in >   "$TMP_TARGET"/debian/control
sed "$ALL_REGEX" "$DISTRIB_TEMPLATES_DIR"/debian_default/dirs.in >      "$TMP_TARGET"/debian/dirs
cp -r "$DISTRIB_TEMPLATES_DIR"/debian_default/{compat,copyright,rules,source} "$TMP_TARGET"/debian/

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

cd "$INITIAL_DIR"
### Clean the buffer for OBS files
TMP_TARGET="$INITIAL_DIR"/obs-tmp/"$SOFTWARE_NAME"
TMP_TARGET=$(realpath -m "$TMP_TARGET")
rm -rf "$TMP_TARGET"

cd "$INITIAL_DIR"
### Put some files in the tarball directory and clean it
# copy the generated Makefile at the root of the tarball
cp "$COMPILATION_TEMPLATES_DIR"/tmp/"$SOFTWARE_NAME"/Makefile "$TARBALL_DIR"/Makefile
# save the local TARBALL_DIR to replace it with the TARBALL_DIR of OBS' VM
echo "$TARBALL_DIR" > "$TARBALL_DIR"/local_build_directory
# restore bin/buildout
# note: when installing python, buildout "rebootstrap" itself to use the installed python: it would fail on OBS' VM
if [ -f "$RUN_BUILDOUT_DIR"/bin/backup.buildout ]; then
	mv "$RUN_BUILDOUT_DIR"/bin/backup.buildout "$RUN_BUILDOUT_DIR"/bin/buildout
fi

# clean the parts directory
rm -rf "$RUN_BUILDOUT_DIR"/{.installed.cfg,parts/}

cd "$INITIAL_DIR"
### Prepare the files for OBS
mkdir -p "$TMP_TARGET"
# -C option allows to give tar an absolute path without archiving the directory from / (i.e. home/user/[...])
tar czf "$TMP_TARGET"/"${SOFTWARE_AND_VERSION}""${ARCHIVE_EXT}" -C "$INITIAL_DIR"/tarballs/ "$SOFTWARE_AND_VERSION"/
tar czf "$TMP_TARGET"/debian.tar.gz -C "$DIST_DIR"/ debian/
cp "$DIST_DIR"/*.dsc "$TMP_TARGET"/
# move the files for OBS
cp "$TMP_TARGET"/"${SOFTWARE_AND_VERSION}""${ARCHIVE_EXT}" "$OBS_DIR"
cp "$TMP_TARGET"/debian.tar.gz "$OBS_DIR"
cp "$TMP_TARGET"/*.dsc "$OBS_DIR"

cd "$OBS_DIR"
osc add *.dsc *.tar.gz
osc commit
