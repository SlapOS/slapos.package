####################################################
# Use on script as source release_configuration.sh
####################################################

INITIAL_DIR="$(pwd)"/

# RELEASE INFORMATION
# Modify the following variables accordingly
VERSION=0
#RECIPE_VERSION=1
RELEASE=1
SOFTWARE_NAME=lunzip

COMPOUND_VERSION=${VERSION}-${RELEASE}
VERSION_NAME=${SOFTWARE_NAME}_${COMPOUND_VERSION}
ARCHIVE_EXT=.tar.gz

# INSTALL INFORMATION
TARGET_DIR=/opt/$VERSION_NAME			# only used for the templates

# OBS AND DISTRIBUTIONS INFORMATION
OBS_DIR=$INITIAL_DIR/home:oph.nxd/$SOFTWARE_NAME/
DIST_DIR=$INITIAL_DIR/distribution-specifics/$SOFTWARE_NAME/
TARBALL_DIR=$INITIAL_DIR/tarballs/$VERSION_NAME

# BUILD INFORMATION
# Modify the following variables accordingly
SR_PATH=$TARBALL_DIR/software_release/component/lunzip/buildout.cfg

TEMPLATE_DIR=$INITIAL_DIR/templates
BUILD_DIR=$TARBALL_DIR/build/	# former BUILD_ROOT_DIRECTORY
# this is where the parts/ directory will be
RUN_BUILDOUT_DIR=$BUILD_DIR/$TARGET_DIR		# former BUILD_DIRECTORY


# Path normalization
INITIAL_DIR=`realpath -m $INITIAL_DIR`
TARGET_DIR=`realpath -m $TARGET_DIR`
OBS_DIR=`realpath -m $OBS_DIR`
DIST_DIR=`realpath -m $DIST_DIR`
TARBALL_DIR=`realpath -m $TARBALL_DIR`
TEMPLATE_DIR=`realpath -m $TEMPLATE_DIR`
BUILD_DIR=`realpath -m $BUILD_DIR`
RUN_BUILDOUT_DIR=`realpath -m $RUN_BUILDOUT_DIR`

# Regular expressions for templates
# versions (not used at the moment)
VERSION_REGEX="s|\%RECIPE_VERSION\%|$RECIPE_VERSION|g;s|\%VERSION\%|$VERSION|g;s|\%RELEASE\%|$RELEASE|g;s|\%COMPOUND_VERSION\%|$COMPOUND_VERSION|g"
# Note: %PATCHES_DIRECTORY% not supported yet
# directories (supporting new macros)
DIR_REGEX="s|\%TARGET_DIR\%|$TARGET_DIR|g;s|\%BUILD_DIR\%|$BUILD_DIR|g;s|\%RUN_BUILDOUT_DIR\%|$RUN_BUILDOUT_DIR|g"
PATH_REGEX="s|\%SR_PATH\%|$SR_PATH|g"
# directories (supporting legacy macros, not used anymore)
#OLD_DIR_REGEX="s|\%TARGET_DIRECTORY\%|$TARGET_DIR|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_DIR|g;s|\%BUILD_DIRECTORY\%|$RUN_BUILDOUT_DIR|g"
# concatenate all regex using ; (quoted, not to end the command)
ALL_REGEX=$VERSION_REGEX";"$DIR_REGEX";"$PATH_REGEX #";"$OLD_DIR_REGEX
