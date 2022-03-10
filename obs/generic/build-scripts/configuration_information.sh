####################################################
# Use on script as source release_configuration.sh
####################################################

INITIAL_DIR="$(pwd)"/

# DEBIAN_REVISION INFORMATION
# Modify the following variables accordingly
SOFTWARE_VERSION=1
#RECIPE_VERSION=1
DEBIAN_REVISION=1
SOFTWARE_NAME=mca

# For the version format, see: https://www.debian.org/doc/manuals/debian-faq/pkg-basics.en.html#pkgname
# here, in <foo>_<VersionNumber>-<DebianRevisionNumber>_<DebianArchitecture>.deb
# VersionNumber is SOFTWARE_VERSION, DebianRevisionNumber is DEBIAN_REVISION
# note: the architecture is added when building the package (here: in OBS)
COMPOUND_VERSION=${SOFTWARE_VERSION}-${DEBIAN_REVISION}
SOFTWARE_AND_VERSION=${SOFTWARE_NAME}_${COMPOUND_VERSION}
ARCHIVE_EXT=.tar.gz

# INSTALL INFORMATION
# TARGET_DIR is only used in the templates via sed regexps
TARGET_DIR=/opt/$SOFTWARE_AND_VERSION

# OBS AND DISTRIBUTIONS INFORMATION
OBS_DIR=$INITIAL_DIR/home:oph.nxd/$SOFTWARE_NAME/
DIST_DIR=$INITIAL_DIR/distribution-specifics/$SOFTWARE_NAME/
TARBALL_DIR=$INITIAL_DIR/tarballs/$SOFTWARE_AND_VERSION

# BUILD INFORMATION
# Modify the following variables accordingly
#SR_PATH=$TARBALL_DIR/software_release/component/$SOFTWARE_NAME/buildout.cfg
SR_PATH=$TARBALL_DIR/software_release/software/$SOFTWARE_NAME/software.cfg

TEMPLATE_DIR=$INITIAL_DIR/templates
# BUILD_DIR was formerly BUILD_ROOT_DIRECTORY
BUILD_DIR=$TARBALL_DIR/build/
# RUN_BUILDOUT_DIR is where the parts/ directory will be ; formerly BUILD_DIRECTORY
RUN_BUILDOUT_DIR=$BUILD_DIR/$TARGET_DIR


# Path normalization
INITIAL_DIR=`realpath -m $INITIAL_DIR`
TARGET_DIR=`realpath -m $TARGET_DIR`
OBS_DIR=`realpath -m $OBS_DIR`
DIST_DIR=`realpath -m $DIST_DIR`
TARBALL_DIR=`realpath -m $TARBALL_DIR`
SR_PATH=`realpath -m $SR_PATH`
TEMPLATE_DIR=`realpath -m $TEMPLATE_DIR`
BUILD_DIR=`realpath -m $BUILD_DIR`
RUN_BUILDOUT_DIR=`realpath -m $RUN_BUILDOUT_DIR`

## Regular expressions for templates
NAME_REGEX="s|%SOFTWARE_NAME%|$SOFTWARE_NAME|g"
# versions (not used at the moment)
# versions (supporting legact macros)
#OLD_VERSION_REGEX="s|\%RECIPE_VERSION\%|$RECIPE_VERSION|g;s|\%VERSION\%|$SOFTWARE_VERSION|g;s|\%DEBIAN_REVISION\%|$DEBIAN_REVISION|g;s|\%COMPOUND_VERSION\%|$COMPOUND_VERSION|g"
# versions (supporting new macros)
VERSION_REGEX="s|%RECIPE_VERSION%|$RECIPE_VERSION|g;s|%SOFTWARE_VERSION%|$SOFTWARE_VERSION|g;s|%DEBIAN_REVISION%|$DEBIAN_REVISION|g;s|%COMPOUND_VERSION%|$COMPOUND_VERSION|g"
# Note: %PATCHES_DIRECTORY% not supported yet
# directories (supporting new macros)
DIR_REGEX="s|%TARGET_DIR%|$TARGET_DIR|g;s|%BUILD_DIR%|$BUILD_DIR|g;s|%RUN_BUILDOUT_DIR%|$RUN_BUILDOUT_DIR|g"
PATH_REGEX="s|%SR_PATH%|$SR_PATH|g"
# directories (supporting legacy macros, not used anymore)
#OLD_DIR_REGEX="s|\%TARGET_DIRECTORY\%|$TARGET_DIR|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_DIR|g;s|\%BUILD_DIRECTORY\%|$RUN_BUILDOUT_DIR|g"
# concatenate all regex using ; (quoted, not to end the command)
ALL_REGEX=$NAME_REGEX";"$VERSION_REGEX";"$DIR_REGEX";"$PATH_REGEX #";"$OLD_DIR_REGEX
