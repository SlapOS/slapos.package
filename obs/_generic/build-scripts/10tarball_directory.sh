#!/bin/bash
set -e

source _generic/build-scripts/00variable-management.sh

# BUILD TREE

cd "$INITIAL_DIR"
### Clean the tarball directory
rm -rf "$TARBALL_DIR"

### Retrieve the buildout directory.
# Note: This is usually a slapos git repository but it can be otherwise.
# There needs to be at least one buildout file to point to (the entry point) which can extend other build files. See the buildout documentation if this is unclear.
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
rm -f "$TARBALL_DIR/Makefile"
rm -f "$RUN_BUILDOUT_DIR/buildout.cfg"

# copy compilation files and override ones with lesser priority
# priority order (example for lunzip_1-1): lunzip_1-1, lunzip, _generic
copy_additional_files "$COMPILATION_FILES_GENERIC_DIR" "$TARBALL_DIR"
if [ -d "$COMPILATION_FILES_SOFTWARE_DIR/_${SOFTWARE_NAME}_generic" ]; then
	copy_additional_files "$COMPILATION_FILES_SOFTWARE_DIR/_${SOFTWARE_NAME}_generic" "$TARBALL_DIR"
	copy_additional_files "$COMPILATION_FILES_DIR/$COMPOUND_VERSION" "$TARBALL_DIR"
else
	copy_additional_files "$COMPILATION_FILES_SOFTWARE_DIR" "$TARBALL_DIR"
fi
mv "$TARBALL_DIR/local_buildout.cfg" "$RUN_BUILDOUT_DIR/buildout.cfg"

# BUILDOUT: BOOTSTRAPING AND RUN

cd "$INITIAL_DIR"
### Remove the products of the buildout bootstraping
# remove the bootstrap script and associated files
rm -f "$RUN_BUILDOUT_DIR"/{bootstrap.py,bootstrap-buildout.py}
# remove the material created by the bootstrap script
rm -rf "$RUN_BUILDOUT_DIR"/{bin,egg}
### Remove the material created by buildout itself
rm -rf "$RUN_BUILDOUT_DIR"/parts

cd "$INITIAL_DIR"
### Download the bootstrap script
mkdir -p "$RUN_BUILDOUT_DIR"
cd "$RUN_BUILDOUT_DIR"
wget https://bootstrap.pypa.io/bootstrap-buildout.py

### Create a $RUN_BUILDOUT_DIR/bin/buildout (bootstraping) and run it (actual compilation).
# Note: it creates a lot of things in $RUN_BUILDOUT_DIR/eggs/ and uses software_release/ at some point
## next line explained
# 1st cmd: bootstrap buildout (creates bin/buildout)
# 2nd cmd: backup $RUN_BUILDOUT_DIR/bin/buildout (to be restored for OBS)
# 3rd cmd: run buildout (which modifies itself via rebootstrapping when compiling python)
(python2.7 -S bootstrap-buildout.py --buildout-version "$ZC_BUILDOUT_VERSION" --setuptools-version "$SETUPTOOLS_VERSION" --setuptools-to-dir eggs -f http://www.nexedi.org/static/packages/source/slapos.buildout/ && cp bin/buildout bin/backup.buildout && ./bin/buildout -v)

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
