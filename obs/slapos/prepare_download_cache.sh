#!/bin/bash

set -e
set -o pipefail

source release_configuration.sh

##########
# VERSION comes from release_configuration.sh
# RECIPE_VERSION comes from release_configuration.sh

TARGET_DIRECTORY=/opt/slapos
BUILD_ROOT_DIRECTORY="$CURRENT_DIRECTORY/$SLAPOS_DIRECTORY/slapos/build"
BUILD_DIRECTORY=$BUILD_ROOT_DIRECTORY$TARGET_DIRECTORY
BUILDOUT_VERSION="2.7.1+slapos020"

rm -rf $BUILD_ROOT_DIRECTORY

echo "Preparing source tarball (recipe version: $RECIPE_VERSION)"
echo " Build Directory: $BUILD_DIRECTORY "
echo " Buildroot Directory: $BUILD_ROOT_DIRECTORY "

########################################################
# build the package once keeping every source in cache #
########################################################

mkdir -p $BUILD_DIRECTORY/{eggs,extends-cache,download-cache/dist,bootstrap-dir}
cd $BUILD_DIRECTORY/bootstrap-dir

# 1) you need a recent enough version of Nexedi buildout, you can do e.g.:
# pip install http://www.nexedi.org/static/packages/source/slapos.buildout/zc.buildout-3.0.1%2Bslapos002.tar.gz

# 2) compile very simple buildout with networkcache
echo "Preparing networkcached zc.buildout"
sed  "s/\%RECIPE_VERSION\%/$RECIPE_VERSION/g;s|\%PATCHES_DIRECTORY\%|$PATCHES_DIRECTORY|g;s|\%TARGET_DIRECTORY\%|$TARGET_DIRECTORY|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_ROOT_DIRECTORY|g;s|\%BUILD_DIRECTORY\%|$BUILD_DIRECTORY|g" $BUILD_ROOT_DIRECTORY/../networkcached.cfg.in > buildout.cfg
# be careful to let 'extra-paths=' in buildout section for isolation
buildout buildout:download-cache=../download-cache bootstrap

# 3) bootstrap the buildout used for full compilation
echo "Launch the bootstrap of final buildout"
cd $BUILD_DIRECTORY
sed  "s/\%RECIPE_VERSION\%/$RECIPE_VERSION/g;s|\%PATCHES_DIRECTORY\%|$PATCHES_DIRECTORY|g;s|\%TARGET_DIRECTORY\%|$TARGET_DIRECTORY|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_ROOT_DIRECTORY|g;s|\%BUILD_DIRECTORY\%|$BUILD_DIRECTORY|g" $BUILD_ROOT_DIRECTORY/../buildout_with_gcc.cfg.in > buildout.cfg
bootstrap-dir/bin/buildout bootstrap

# 4) build locally everything with gcc to get download-cache and extends-cache ready
echo "Launch the big buildout to compile everything"
bin/buildout buildout:newest=true -v | tee buildout-full.log



###################################################
# remove all files from build keeping only caches #
###################################################

echo "Deleting unecessary files to reduce source tarball size"

# TODO: Figure out why there is no write permission even for
#       the owner
chmod -R u+w .

rm -fv .installed.cfg environment.*
rm -rfv ./{downloads,parts,eggs,develop-eggs,bin,rebootstrap}

# Removing empty directories
find . -type d -empty -prune -exec rmdir '{}' ';'

# Removing Python byte-compiled files (as it will be done upon
# package installation) and static libraries
find . -regextype posix-extended -type f \
	-iregex '.*/*\.(py[co]|[l]?a|exe|bat)$$' -exec rm -fv '{}' ';'

#TODO remove git files


##################################
# prepare compilation inside OBS #
##################################

# we need the original directory to do a sed inside OBS
# TODO remove this and properly use extends-cache instead
echo "$BUILD_ROOT_DIRECTORY" > $CURRENT_DIRECTORY/$SLAPOS_DIRECTORY/slapos/original_directory

# in OBS build, don't force gcc build
sed  "s/\%RECIPE_VERSION\%/$RECIPE_VERSION/g;s|\%PATCHES_DIRECTORY\%|$PATCHES_DIRECTORY|g;s|\%TARGET_DIRECTORY\%|$TARGET_DIRECTORY|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_ROOT_DIRECTORY|g;s|\%BUILD_DIRECTORY\%|$BUILD_DIRECTORY|g" $BUILD_ROOT_DIRECTORY/../buildout_without_gcc.cfg.in > $BUILD_DIRECTORY/buildout.cfg


