#!/bin/bash
set -e

source _generic/build-scripts/00env.sh

# BUILD TREE

### Clean the tarball directory
rm -rf "$TARBALL_DIR"

### Retrieve the buildout directory.
mkdir -p "$TARBALL_DIR"
git clone "$GIT_REPOSITORY" "$BUILDOUT_DIR"
cd "$BUILDOUT_DIR"
git checkout "$GIT_BRANCH_OR_COMMIT"
cd "$INITIAL_DIR"

### Prepare the build directories
mkdir -p "$RUN_BUILDOUT_DIR"/{eggs,extends-cache,download-cache/dist}

# COMPILATION FILES

### Prepare the compilation files

# copy compilation files and override the files from _generic
# with the one from <software_name>
copy_and_solve_templates "$COMPILATION_FILES_GENERIC_DIR" "$TARBALL_DIR"
copy_and_solve_templates "$COMPILATION_FILES_SOFTWARE_DIR" "$TARBALL_DIR"

# BUILDOUT: BOOTSTRAPING AND RUN

echo "Preparing bootstrap zc.buildout..."
mkdir -p "$RUN_BUILDOUT_DIR/bootstrap-dir"
cd "$RUN_BUILDOUT_DIR/bootstrap-dir"
cp "$TARBALL_DIR"/20cache-and-use-libnetworkcache.cfg buildout.cfg
buildout buildout:download-cache=../download-cache bootstrap

echo "Run buildout for the local compilation..."
cd "$RUN_BUILDOUT_DIR"
cp "$TARBALL_DIR"/30local_buildout.cfg buildout.cfg
bootstrap-dir/bin/buildout bootstrap
bin/buildout buildout:newest=true -v | tee buildout-full.log

### Fix the go/ directory.

# For some reason the user does not have the "write" permission on some directories within $RUN_BUILDOUT_DIR/go/. As it is
# needed on a directory to delete a file in it, the if block adds the permissions to every
# directories in go/.
# This is performed before copying the directory tree elsewhere so that every copy is fixed.
# It also allows the cleaning script to delete the result of the current script.
if [ -d "$RUN_BUILDOUT_DIR"/go ]; then
	find "$RUN_BUILDOUT_DIR"/go -type d -exec chmod u+xw {} +
fi

### Backup $TARBALL_DIR for debugging or other purpose
# add "backup." before the directory name pointed to by $TARBALL_DIR
BACKUP_DIR="$TARBALL_DIR"/../backup."$SOFTWARE_AND_VERSION"
rm -rf "$BACKUP_DIR"
cp -r "$TARBALL_DIR" "$BACKUP_DIR"
