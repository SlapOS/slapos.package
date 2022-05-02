#!/bin/bash

set -e

source release_configuration.sh

##########
# VERSION comes from release_configuration.sh
# RECIPE_VERSION comes from release_configuration.sh

TARGET_DIRECTORY=/opt/slapos
BUILD_ROOT_DIRECTORY="$CURRENT_DIRECTORY/$SLAPOS_DIRECTORY/slapos/build"
BUILD_DIRECTORY=$BUILD_ROOT_DIRECTORY$TARGET_DIRECTORY
BUILDOUT_VERSION="2.7.1+slapos019"

rm -rf $BUILD_ROOT_DIRECTORY

echo "Preparing source tarball (recipe version: $RECIPE_VERSION)"
echo " Build Directory: $BUILD_DIRECTORY "
echo " Buildroot Directory: $BUILD_ROOT_DIRECTORY "

mkdir -p $BUILD_DIRECTORY/{eggs,extends-cache,download-cache,download-cache/dist}

cd $BUILD_DIRECTORY
# Download  bootstrap file
wget https://lab.nexedi.com/nexedi/slapos.buildout/raw/master/bootstrap/bootstrap.py

# 1) boostrap with old version
echo "bootsrapping buildout"
sed  "s/\%RECIPE_VERSION\%/$RECIPE_VERSION/g;s|\%PATCHES_DIRECTORY\%|$PATCHES_DIRECTORY|g;s|\%TARGET_DIRECTORY\%|$TARGET_DIRECTORY|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_ROOT_DIRECTORY|g;s|\%BUILD_DIRECTORY\%|$BUILD_DIRECTORY|g" $BUILD_ROOT_DIRECTORY/../slapos.buildout.cfg.in > buildout.cfg 

python3 -S bootstrap.py \
  --setuptools-version 40.8.0 \
  --setuptools-to-dir eggs

# 2) get newest version of zc.buildout and setuptools
#    note that we can't directly do setuptools + zc.buildout +
#    slapos.libnetworkcache because buildout would be relaunched in the middle
#    without the "-S" option to python
echo "downloading good version of setuptools and zc.buildout"
sed -i '1s/$/ -S/' bin/buildout
sed -i "/def _satisfied(/s/\(\bsource=\)None/\11/" eggs/zc.buildout-*/zc/buildout/easy_install.py # no wheel
bin/buildout buildout:newest=true -v
[ "$(ls download-cache/dist/*.whl)" != "" ] || { echo "There shouldn't be any wheel in download-cache" ; exit 1 ; }

# 3) compile very simple buildout with networkcache
echo "Preparing networkcached zc.buildout"
sed  "s/\%RECIPE_VERSION\%/$RECIPE_VERSION/g;s|\%PATCHES_DIRECTORY\%|$PATCHES_DIRECTORY|g;s|\%TARGET_DIRECTORY\%|$TARGET_DIRECTORY|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_ROOT_DIRECTORY|g;s|\%BUILD_DIRECTORY\%|$BUILD_DIRECTORY|g" $BUILD_ROOT_DIRECTORY/../networkcached.cfg.in > buildout.cfg 
sed -i '1s/$/ -S/' bin/buildout
bin/buildout buildout:newest=true -v

# 4) build locally everything with gcc to get download-cache and extends-cache ready
echo "Launch the big buildout to compile everything"
sed  "s/\%RECIPE_VERSION\%/$RECIPE_VERSION/g;s|\%PATCHES_DIRECTORY\%|$PATCHES_DIRECTORY|g;s|\%TARGET_DIRECTORY\%|$TARGET_DIRECTORY|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_ROOT_DIRECTORY|g;s|\%BUILD_DIRECTORY\%|$BUILD_DIRECTORY|g" $BUILD_ROOT_DIRECTORY/../buildout_with_gcc.cfg.in > buildout.cfg

echo "$BUILD_ROOT_DIRECTORY" > $CURRENT_DIRECTORY/$SLAPOS_DIRECTORY/slapos/original_directory

bin/buildout buildout:newest=true -v

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

##############################
# prepare rebootstrap script #
##############################


# in OBS build, don't force gcc build
sed  "s/\%RECIPE_VERSION\%/$RECIPE_VERSION/g;s|\%PATCHES_DIRECTORY\%|$PATCHES_DIRECTORY|g;s|\%TARGET_DIRECTORY\%|$TARGET_DIRECTORY|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_ROOT_DIRECTORY|g;s|\%BUILD_DIRECTORY\%|$BUILD_DIRECTORY|g" $BUILD_ROOT_DIRECTORY/../buildout_without_gcc.cfg.in > $BUILD_DIRECTORY/buildout.cfg
exit 1

