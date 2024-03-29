#!/bin/bash
set -e

source _generic/build-scripts/00env.sh

# DISTRIBUTION FILES

### Prepare the distribution files in $OBS_DIR
osc checkout "$OBS_PROJECT" "$OBS_PACKAGE" || true
cd "$OBS_DIR"
osc update
osc rm "$SOFTWARE_NAME"_*"$ARCHIVE_EXT" "$SOFTWARE_AND_VERSION".dsc || true
cd "$INITIAL_DIR"

# copy compilation files and override the files from _generic
# with the one from <software_name>
copy_and_solve_templates "$DISTRIB_FILES_GENERIC_DIR" "$OBS_DIR"
mv "$OBS_DIR"/_generic.dsc "$OBS_DIR/$SOFTWARE_NAME.dsc"
mv "$OBS_DIR"/_generic.spec "$OBS_DIR/$SOFTWARE_NAME.spec"
copy_and_solve_templates "$DISTRIB_FILES_SOFTWARE_DIR" "$OBS_DIR"

# ARCHIVES FILES

### Finalize the tarball directory preparation
# switch to the buildout wrapper for OBS
cp "$TARBALL_DIR"/40obs_buildout.cfg "$RUN_BUILDOUT_DIR"/buildout.cfg
# save the local $TARBALL_DIR path so that it is replaced by the $TARBALL_DIR path from OBS' VM
echo "$TARBALL_DIR" > "$TARBALL_DIR"/local_tarball_directory_path
# add a stamp so that OBS does not clean the local preparation before compiling
touch "$TARBALL_DIR/clean-stamp"
# copy required eggs that are not cached
# clean the compilation related files
rm -rf "$RUN_BUILDOUT_DIR"/{.installed.cfg,downloads,parts,eggs,develop-eggs,bin,rebootstrap}

rm -rf "$BUILDOUT_DIR"/.git # lighten what is sent to OBS
# TODO: support extends-cache

### Prepare the archives for OBS
# -C option allows to give tar an absolute path without archiving the directory from / (i.e. home/user/[...])
tar czf "$OBS_DIR/$SOFTWARE_AND_VERSION$ARCHIVE_EXT" -C "$INITIAL_DIR/_tarballs" "$SOFTWARE_AND_VERSION"
tar czf "$OBS_DIR/debian$ARCHIVE_EXT" -C "$OBS_DIR" debian

# OBS COMMIT

cd "$OBS_DIR"
osc add *.spec *.dsc *"$ARCHIVE_EXT"
if [ -n "$OBS_COMMIT_MSG" ]; then
	osc commit -m "$OBS_COMMIT_MSG"
else
	osc commit
fi
