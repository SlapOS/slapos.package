####################################################
# Use on script as source release_configuration.sh
####################################################

INITIAL_DIR="$(pwd)"
# Modify the following variables accordingly

# RELEASE INFORMATION
VERSION=1
RECIPE_VERSION=1
RELEASE=1
SOFTWARE=lunzip

# INSTALL INFORMATION
TARGET_DIR=/opt/${SOFTWARE}_software_release

# BUILD INFORMATION
TEMPLATE_DIR=$INITIAL_DIR/template
BUILD_DIR=$INITIAL_DIR/tarball/$SOFTWARE/build/	# former BUILD_ROOT_DIRECTORY
PARTS_DIR=$BUILD_DIR/$TARGET_DIR		# former BUILD_DIRECTORY

# OBS INFORMATION
OBS_DIR=$INITIAL_DIR/home:oph.nxd/$SOFTWARE/


# Path normalization
INITIAL_DIR=`realpath -m $INITIAL_DIR`
TARGET_DIR=`realpath -m $TARGET_DIR`
TEMPLATE_DIR=`realpath -m $TEMPLATE_DIR`
BUILD_DIR=`realpath -m $BUILD_DIR`
PARTS_DIR=`realpath -m $PARTS_DIR`

# Regular expressions for templates
VERSION_REGEX="s/\%RECIPE_VERSION\%/$RECIPE_VERSION/g;s/\%VERSION\%/$VERSION/g;s/\%RELEASE\%/$RELEASE/g"
# Note: %PATCHES_DIRECTORY% not supported yet
# supporting legacy macros
DIR_REGEX="s|\%TARGET_DIRECTORY\%|$TARGET_DIR|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_DIR|g;s|\%BUILD_DIRECTORY\%|$PARTS_DIR|g"
# supporting new macros
#DIR_REGEX="s|\%TARGET_DIR\%|$TARGET_DIR|g;s|\%BUILD_DIR\%|$BUILD_DIR|g;s|\%PARTS_DIR\%|$PARTS_DIR|g"

