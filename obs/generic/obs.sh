#!/bin/bash
set -e

source configuration_information.sh

TMP_DIR=$INITIAL_DIR/tmp/
TMP_DIR=`realpath -m $TMP_DIR`
echo TMP_DIR = $TMP_DIR
mkdir -p $TMP_DIR
# clean the build directory for OBS
rm -rf $RUN_BUILDOUT_DIR/parts/
# prepare the files for OBS

# -C option allows to give tar an absolute path without archiving the directory from / (i.e. home/user/[...])
tar czf $TMP_DIR/$SOFTWARE.tar.gz -C tarballs/ $SOFTWARE/
tar czf $TMP_DIR/debian.tar.gz -C $DIST_DIR/ debian/
cp $DIST_DIR/*.dsc $TMP_DIR/
# move the files for OBS
cp $TMP_DIR/$SOFTWARE.tar.gz $OBS_DIR
cp $TMP_DIR/debian.tar.gz $OBS_DIR
cp $TMP_DIR/*.dsc $OBS_DIR

cd $OBS_DIR
osc commit
