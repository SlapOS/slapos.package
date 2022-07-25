#!/bin/bash
set -e

source build-scripts/00env.sh

cd "$INITIAL_DIR"
### Prepare the distribution files in $OBS_DIR
osc checkout "$OBS_PROJECT" "$SOFTWARE_NAME" || true

rm -f "$OBS_DIR/lunzip_$COMPOUND_VERSION.dsc"
rm -f "$OBS_DIR/debian.tar.gz"
rm -rf "$OBS_DIR/debian"

sed "$ALL_REGEX" "$DISTRIB_FILES_DIR/lunzip.dsc.in" > "$OBS_DIR/lunzip_$COMPOUND_VERSION.dsc"
mkdir -p "$OBS_DIR/debian"
sed "$ALL_REGEX" "$DISTRIB_FILES_DIR/debian/changelog.in" > "$OBS_DIR/debian/changelog"
cp -r "$DISTRIB_FILES_DIR/debian/"{compat,control,copyright,dirs,rules,source} "$OBS_DIR/debian"

cd "$INITIAL_DIR"
### Finalize the tarball directory preparation
# save the local $TARBALL_DIR path so that it is replaced by the $TARBALL_DIR path from OBS' VM
echo "$TARBALL_DIR" > "$TARBALL_DIR"/local_tarball_directory_path
# add a stamp so that OBS does not clean the local preparation before compiling
touch "$TARBALL_DIR/clean-stamp"
# restore bin/buildout
# note: when installing python, buildout "rebootstraps" itself to use the installed python:
# it modifies its own shebang, which would fail on OBS' VM (no such file or directory)
if [ -f "$RUN_BUILDOUT_DIR"/bin/backup.buildout ]; then
	mv "$RUN_BUILDOUT_DIR"/bin/backup.buildout "$RUN_BUILDOUT_DIR"/bin/buildout
fi
# clean the compilation related files
rm -rf "$RUN_BUILDOUT_DIR"/{.installed.cfg,parts}

cd "$INITIAL_DIR"
### Prepare the archives for OBS
# -C option allows to give tar an absolute path without archiving the directory from / (i.e. home/user/[...])
tar czf "$OBS_DIR/$SOFTWARE_AND_VERSION$ARCHIVE_EXT" -C "$INITIAL_DIR/tarballs" "$SOFTWARE_AND_VERSION"
tar czf "$OBS_DIR/debian$ARCHIVE_EXT" -C "$OBS_DIR" debian

cd "$OBS_DIR"
osc add *.dsc *"$ARCHIVE_EXT"
if [ -n "$OBS_COMMIT_MSG" ]; then
	osc commit -m "$OBS_COMMIT_MSG"
else
	osc commit
fi
