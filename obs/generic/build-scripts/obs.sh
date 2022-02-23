#!/bin/bash
set -e

source build-scripts/configuration_information.sh

# temporary directory for the files needed by OBS
TMP_DIR=$INITIAL_DIR/tmp/
TMP_DIR=`realpath -m $TMP_DIR`
echo TMP_DIR = $TMP_DIR

# copy the Makefile at the root of the tarball
cp $TEMPLATE_DIR/tmp/Makefile $TARBALL_DIR/Makefile
# save the local TARBALL_DIR to replace it with the TARBALL_DIR of OBS' VM
echo $TARBALL_DIR > $TARBALL_DIR/cache_creation_build_directory

# clean the parts directory
rm -rf $RUN_BUILDOUT_DIR/{.installed.cfg,parts/}

## prepare the files for OBS
mkdir -p $TMP_DIR
# -C option allows to give tar an absolute path without archiving the directory from / (i.e. home/user/[...])
tar czf $TMP_DIR/${VERSION_NAME}${ARCHIVE_EXT} -C $INITIAL_DIR/tarballs/ $VERSION_NAME/
tar czf $TMP_DIR/debian.tar.gz -C $DIST_DIR/ debian/
cp $DIST_DIR/*.dsc $TMP_DIR/
# move the files for OBS
cp $TMP_DIR/${VERSION_NAME}${ARCHIVE_EXT} $OBS_DIR
cp $TMP_DIR/debian.tar.gz $OBS_DIR
cp $TMP_DIR/*.dsc $OBS_DIR

cd $OBS_DIR
osc commit
