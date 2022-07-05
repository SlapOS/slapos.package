####################################################
# Use on script as source release_configuration.sh
####################################################

INITIAL_DIR="$(pwd)"/

### DEBIAN_REVISION INFORMATION ###
# Modify the following variables accordingly
SOFTWARE_VERSION=1
#RECIPE_VERSION=1
DEBIAN_REVISION=1
SOFTWARE_NAME=dep--mca--static

# For the version format, see: https://www.debian.org/doc/manuals/debian-faq/pkg-basics.en.html#pkgname
# here, in <foo>_<VersionNumber>-<DebianRevisionNumber>_<DebianArchitecture>.deb
# VersionNumber is SOFTWARE_VERSION, DebianRevisionNumber is DEBIAN_REVISION
# note: the architecture is added when building the package (here: in OBS)
COMPOUND_VERSION="${SOFTWARE_VERSION}-${DEBIAN_REVISION}"
SOFTWARE_AND_VERSION="${SOFTWARE_NAME}_${COMPOUND_VERSION}"
ARCHIVE_EXT=.tar.gz

### INSTALL INFORMATION ###
# TARGET_DIR is only used in the templates via sed regexps
TARGET_DIR=/opt/"$SOFTWARE_AND_VERSION"

### OBS AND DISTRIBUTIONS INFORMATION ###
# get the user from osc configuration file
OBS_USER="$(cat ~/.config/osc/oscrc | grep user= | cut -d'=' -f2)"
OBS_PROJECT="home:$OBS_USER"
OBS_DIR="$INITIAL_DIR/$OBS_PROJECT/$SOFTWARE_NAME/"
DIST_DIR="$INITIAL_DIR/distribution-specifics/$SOFTWARE_NAME/"
TARBALL_DIR="$INITIAL_DIR/tarballs/$SOFTWARE_AND_VERSION"

### BUILD INFORMATION ###
# Modify the following variables accordingly
# this is the directory with the buildout files, it can be anything but it usually is a slapos repository
BUILDOUT_DIR="$TARBALL_DIR/slapos_repository/"
# this can also be a component rather than a software, replace "software" with "component" and "buildout" to use a component instead
BUILDOUT_ENTRY_POINT="$BUILDOUT_DIR/software/$SOFTWARE_NAME/software.cfg"

COMPILATION_TEMPLATES_DIR="$INITIAL_DIR/templates/compilation-templates/"
# BUILD_DIR was formerly BUILD_ROOT_DIRECTORY
BUILD_DIR="$TARBALL_DIR/build/"
# RUN_BUILDOUT_DIR is where the parts/ directory will be ; formerly BUILD_DIRECTORY
RUN_BUILDOUT_DIR="$BUILD_DIR/$TARGET_DIR"
DISTRIB_TEMPLATES_DIR="$INITIAL_DIR/templates/distribution-templates"
DISTRIB_FILES_DIR="$INITIAL_DIR/distribution-specifics/$SOFTWARE_NAME"


## Path normalization
INITIAL_DIR=$(realpath -m "$INITIAL_DIR")
TARGET_DIR=$(realpath -m "$TARGET_DIR")
OBS_DIR=$(realpath -m "$OBS_DIR")
DIST_DIR=$(realpath -m "$DIST_DIR")
TARBALL_DIR=$(realpath -m "$TARBALL_DIR")
BUILDOUT_DIR=$(realpath -m "$BUILDOUT_DIR")
BUILDOUT_ENTRY_POINT=$(realpath -m "$BUILDOUT_ENTRY_POINT")
COMPILATION_TEMPLATES_DIR=$(realpath -m "$COMPILATION_TEMPLATES_DIR")
BUILD_DIR=$(realpath -m "$BUILD_DIR")
RUN_BUILDOUT_DIR=$(realpath -m "$RUN_BUILDOUT_DIR")
DISTRIB_TEMPLATES_DIR=$(realpath -m "$DISTRIB_TEMPLATES_DIR")
DISTRIB_FILES_DIR=$(realpath -m "$DISTRIB_FILES_DIR")

## Regular expressions for templates
NAME_REGEX="s|%SOFTWARE_NAME%|$SOFTWARE_NAME|g;s|%SOFTWARE_AND_VERSION%|$SOFTWARE_AND_VERSION|g"
# versions (not used at the moment)
# versions (supporting legact macros)
#OLD_VERSION_REGEX="s|\%RECIPE_VERSION\%|$RECIPE_VERSION|g;s|\%VERSION\%|$SOFTWARE_VERSION|g;s|\%DEBIAN_REVISION\%|$DEBIAN_REVISION|g;s|\%COMPOUND_VERSION\%|$COMPOUND_VERSION|g"
# versions (supporting new macros)
VERSION_REGEX="s|%RECIPE_VERSION%|$RECIPE_VERSION|g;s|%SOFTWARE_VERSION%|$SOFTWARE_VERSION|g;s|%DEBIAN_REVISION%|$DEBIAN_REVISION|g;s|%COMPOUND_VERSION%|$COMPOUND_VERSION|g"
# Note: %PATCHES_DIRECTORY% not supported yet
# directories (supporting new macros)
DIR_REGEX="s|%TARGET_DIR%|$TARGET_DIR|g;s|%BUILD_DIR%|$BUILD_DIR|g;s|%RUN_BUILDOUT_DIR%|$RUN_BUILDOUT_DIR|g"
PATH_REGEX="s|%BUILDOUT_ENTRY_POINT%|$BUILDOUT_ENTRY_POINT|g"
# directories (supporting legacy macros, not used anymore)
#OLD_DIR_REGEX="s|\%TARGET_DIRECTORY\%|$TARGET_DIR|g;s|\%BUILD_ROOT_DIRECTORY\%|$BUILD_DIR|g;s|\%BUILD_DIRECTORY\%|$RUN_BUILDOUT_DIR|g"
# concatenate all regex using ; (quoted, not to end the command)
ALL_REGEX=$NAME_REGEX";"$VERSION_REGEX";"$DIR_REGEX";"$PATH_REGEX #";"$OLD_DIR_REGEX
