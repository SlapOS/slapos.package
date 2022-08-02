#!/bin/bash
set -e

source build-scripts/00env.sh

# DISTRIBUTION FILES

cd "$INITIAL_DIR"
### Prepare the distribution files in $OBS_DIR
osc checkout "$OBS_PROJECT" "$SOFTWARE_NAME" || true

copy_additional_files "$DISTRIB_FILES_DIR/_generic" "$OBS_DIR"
mv "$OBS_DIR/_generic.dsc" "$OBS_DIR/$SOFTWARE_NAME.dsc"
copy_additional_files "$DISTRIB_FILES_DIR/$SOFTWARE_NAME" "$OBS_DIR"
copy_additional_files "$DISTRIB_FILES_DIR/$SOFTWARE_AND_VERSION" "$OBS_DIR"

# ARCHIVES FILES

cd "$INITIAL_DIR"
### Finalize the tarball directory preparation
# save the local $TARBALL_DIR path so that it is replaced by the $TARBALL_DIR path from OBS' VM
echo "$TARBALL_DIR" > "$TARBALL_DIR"/local_tarball_directory_path
# restore bin/buildout
# note: when installing python, buildout "rebootstraps" itself to use the installed python:
# it modifies its own shebang, which would fail on OBS' VM (no such file or directory)
if [ -f "$RUN_BUILDOUT_DIR"/bin/backup.buildout ]; then
	mv "$RUN_BUILDOUT_DIR"/bin/backup.buildout "$RUN_BUILDOUT_DIR"/bin/buildout
fi
# clean the compilation related files
rm -rf "$RUN_BUILDOUT_DIR"/{.installed.cfg,parts/}

cd "$INITIAL_DIR"
### Prepare the archives for OBS
# -C option allows to give tar an absolute path without archiving the directory from / (i.e. home/user/[...])
tar czf "$OBS_DIR/$SOFTWARE_AND_VERSION$ARCHIVE_EXT" -C "$INITIAL_DIR/tarballs" "$SOFTWARE_AND_VERSION"
tar czf "$OBS_DIR/debian$ARCHIVE_EXT" -C "$OBS_DIR" debian

# OBS COMMIT

cd "$OBS_DIR"
osc add *.dsc *"$ARCHIVE_EXT"
if [ -n "$OBS_COMMIT_MSG" ]; then
	osc commit -m "$OBS_COMMIT_MSG"
else
	osc commit
fi
