#!/bin/bash
set -e

source build-scripts/00env.sh

# temporary directory for the files needed by OBS
TMP_TARGET="$INITIAL_DIR"/obs-tmp/"$SOFTWARE_NAME"
TMP_TARGET=$(realpath -m "$TMP_TARGET")
echo TMP_TARGET = "$TMP_TARGET"

# copy the generated Makefile at the root of the tarball
cp "$COMPILATION_TEMPLATES_DIR"/tmp/"$SOFTWARE_NAME"/Makefile "$TARBALL_DIR"/Makefile
# save the local TARBALL_DIR to replace it with the TARBALL_DIR of OBS' VM
echo "$TARBALL_DIR" > "$TARBALL_DIR"/local_build_directory
# restore bin/buildout
# note: when installing python, buildout "rebootstrap" itself to use the installed python: it would fail on OBS' VM
mv "$RUN_BUILDOUT_DIR"/bin/backup.buildout "$RUN_BUILDOUT_DIR"/bin/buildout

# clean the parts directory
rm -rf "$RUN_BUILDOUT_DIR"/{.installed.cfg,parts/}

## prepare the files for OBS
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
