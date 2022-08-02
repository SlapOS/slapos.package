#!/bin/bash
set -e

source _generic/build-scripts/00env.sh

# BUILD TREE

cd "$INITIAL_DIR"
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

cd "$INITIAL_DIR"
### Prepare the compilation files

# copy compilation files and override the files from _generic
# with the one from <software_name>
copy_and_solve_templates "$COMPILATION_FILES_GENERIC_DIR" "$TARBALL_DIR"
copy_and_solve_templates "$COMPILATION_FILES_SOFTWARE_DIR" "$TARBALL_DIR"
mv "$TARBALL_DIR/local_buildout.cfg" "$RUN_BUILDOUT_DIR/buildout.cfg"

# BUILDOUT: BOOTSTRAPING AND RUN

cd "$INITIAL_DIR"
### Download the bootstrap script
mkdir -p "$RUN_BUILDOUT_DIR"
cd "$RUN_BUILDOUT_DIR"
wget https://bootstrap.pypa.io/bootstrap-buildout.py

### Run buildout
# Note: it creates a lot of things in $RUN_BUILDOUT_DIR/eggs/ and uses software_release/ at some point
## next line explained
# 1st cmd: bootstrap buildout (creates $RUN_BUILDOUT_DIR/bin/buildout)
# 2nd cmd: backup $RUN_BUILDOUT_DIR/bin/buildout (to be restored for OBS)
# 3rd cmd: run $RUN_BUILDOUT_DIR/bin/buildout (note that it modifies itself via rebootstrapping when compiling python)
python2.7 -S bootstrap-buildout.py \
	--buildout-version "$ZC_BUILDOUT_VERSION" \
	--setuptools-version "$SETUPTOOLS_VERSION" \
	--setuptools-to-dir eggs -f http://www.nexedi.org/static/packages/source/slapos.buildout/
cp bin/buildout bin/backup.buildout
./bin/buildout -v

cd "$INITIAL_DIR"
### Fix the go/ directory.

# For some reason the user does not have the "write" permission on some directories within $RUN_BUILDOUT_DIR/go/. As it is
# needed on a directory to delete a file in it, the if block adds the permissions to every
# directories in go/.
# This is performed before copying the directory tree elsewhere so that every copy is fixed.
# It also allows the cleaning script to delete the result of the current script.
if [ -d "$RUN_BUILDOUT_DIR"/go ]; then
	find "$RUN_BUILDOUT_DIR"/go -type d -exec chmod u+xw {} +
fi

cd "$INITIAL_DIR"
### Backup $TARBALL_DIR for debugging or other purpose
# add "backup." before the directory name pointed to by $TARBALL_DIR
BACKUP_DIR="$TARBALL_DIR"/../backup."$SOFTWARE_AND_VERSION"
BACKUP_DIR=$(realpath -m "$BACKUP_DIR")
rm -rf "$BACKUP_DIR"
cp -r "$TARBALL_DIR" "$BACKUP_DIR"

cd "$INITIAL_DIR"
### Switch to the buildout wrapper for OBS
mv "$TARBALL_DIR/obs_buildout.cfg" "$RUN_BUILDOUT_DIR/buildout.cfg"
