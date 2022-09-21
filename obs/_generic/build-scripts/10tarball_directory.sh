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

### Download the bootstrap script
mkdir -p "$RUN_BUILDOUT_DIR"
cd "$RUN_BUILDOUT_DIR"
wget https://lab.nexedi.com/nexedi/slapos.buildout/raw/master/bootstrap/bootstrap.py

### Run buildout
# Note: it creates a lot of things in $RUN_BUILDOUT_DIR/eggs/ and uses software_release/ at some point

# 00) Bootstrap buildout with an old version.
#    no --buildout-version option, so it uses an upstream version of buildout
#    creates $RUN_BUILDOUT_DIR/bin/buildout
echo "[buildout]" > buildout.cfg # dummy .cfg file only for boostraping
echo "Bootsrapping buildout..."
python3 -S bootstrap.py \
	--setuptools-version 44.1.0 \
	--setuptools-to-dir eggs

# 10) Get newest version of zc.buildout and setuptools.
#    note that we can't directly do setuptools + zc.buildout +
#    slapos.libnetworkcache because buildout would be relaunched in the middle
#    without the "-S" option to python
echo "Downloading the desired version of setuptools and zc.buildout..."
cp "$TARBALL_DIR"/10cache-zc-buildout.cfg buildout.cfg
sed -i '1s/$/ -S/' bin/buildout
sed -i "/def _satisfied(/s/\(\bsource=\)None/\11/" eggs/zc.buildout-*/zc/buildout/easy_install.py # no wheel
bin/buildout buildout:newest=true -v
ls download-cache/dist/*.whl && { echo "There shouldn't be any wheel in download-cache" ; exit 1 ; }

# 20) Compile a very simple buildout with networkcache.
echo "Preparing networkcached zc.buildout..."
cp "$TARBALL_DIR"/20cache-and-use-libnetworkcache.cfg buildout.cfg
sed -i '1s/$/ -S/' bin/buildout
bin/buildout buildout:newest=true -v

# 30) Run $RUN_BUILDOUT_DIR/bin/buildout.
#    note that it modifies itself via rebootstrapping when compiling python
#    build locally everything with gcc to get download-cache and extends-cache ready
echo "Finally running buildout for the local compilation..."
cp "$TARBALL_DIR"/30local_buildout.cfg buildout.cfg
bin/buildout buildout:newest=true -v

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
