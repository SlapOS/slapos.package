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
TEMPLATE_DIR=$INITIAL_DIR/templates
BUILD_DIR=$INITIAL_DIR/tarballs/$SOFTWARE/build/	# former BUILD_ROOT_DIRECTORY
# this is where the parts/ directory will be
RUN_BUILDOUT_DIR=$BUILD_DIR/$TARGET_DIR		# former BUILD_DIRECTORY

# OBS AND DISTRIBUTIONS INFORMATION
OBS_DIR=$INITIAL_DIR/home:oph.nxd/$SOFTWARE/
DIST_DIR=$INITIAL_DIR/distribution-specifics/$SOFTWARE/


# Path normalization
INITIAL_DIR=`realpath -m $INITIAL_DIR`
TARGET_DIR=`realpath -m $TARGET_DIR`
TEMPLATE_DIR=`realpath -m $TEMPLATE_DIR`
BUILD_DIR=`realpath -m $BUILD_DIR`
RUN_BUILDOUT_DIR=`realpath -m $RUN_BUILDOUT_DIR`
OBS_DIR=`realpath -m $OBS_DIR`
DIST_DIR=`realpath -m $DIST_DIR`

# Regular expressions for templates
VERSION_REGEX="s/\%RECIPE_VERSION\%/$RECIPE_VERSION/g;s/\%VERSION\%/$VERSION/g;s/\%RELEASE\%/$RELEASE/g"
# Note: %PATCHES_DIRECTORY% not supported yet
# supporting new macros
DIR_REGEX="s|\%TARGET_DIR\%|$TARGET_DIR|g;s|\%BUILD_DIR\%|$BUILD_DIR|g;s|\%RUN_BUILDOUT_DIR\%|$RUN_BUILDOUT_DIR|g"
# supporting legacy macros
OLD_DIR_REGEX="s|\%TARGET_DIRECTORY\%|$TARGET_DIR|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_DIR|g;s|\%BUILD_DIRECTORY\%|$RUN_BUILDOUT_DIR|g"
# concatenate all regex using ; (quoted, not to end the command)
ALL_REGEX=$VERSION_REGEX";"$DIR_REGEX";"$OLD_DIR_REGEX
