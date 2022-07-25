####################################################
# Use on script as source release_configuration.sh
####################################################

INITIAL_DIR=$(pwd)/
INITIAL_DIR=$(realpath -m "$INITIAL_DIR")

if [ ! -f "$INITIAL_DIR"/build-scripts/custom-env/"$(NAME)"_env.sh ]; then
	source "$INITIAL_DIR"/build-scripts/custom-env/"${NAME}"_env.sh
fi

### DEBIAN_REVISION INFORMATION ###
SOFTWARE_VERSION=${SOFTWARE_VERSION:-1}
DEBIAN_REVISION=${DEBIAN_REVISINO:-1}
SOFTWARE_NAME=${SOFTWARE_NAME:-$NAME}

# For the version format, see: https://www.debian.org/doc/manuals/debian-faq/pkg-basics.en.html#pkgname
# here, in <foo>_<VersionNumber>-<DebianRevisionNumber>_<DebianArchitecture>.deb
# VersionNumber is SOFTWARE_VERSION, DebianRevisionNumber is DEBIAN_REVISION
# note: the architecture is added when building the package (here: in OBS)
COMPOUND_VERSION=${COMPOUND_VERSION:-${SOFTWARE_VERSION}-${DEBIAN_REVISION}}
SOFTWARE_AND_VERSION=${SOFTWARE_AND_VERSION:-${SOFTWARE_NAME}_${COMPOUND_VERSION}}
ARCHIVE_EXT=${ARCHIVE_EXT:-.tar.gz}

### INSTALL INFORMATION ###
# This is the directory you want your package to install your software in.
# Use "/" for building an official distribution package.
TARGET_DIR="${TARGET_DIR:-/opt/$SOFTWARE_AND_VERSION}"

### BUILD INFORMATION ###
TARBALL_DIR=${TARBALL_DIR:-$INITIAL_DIR/tarballs/$SOFTWARE_AND_VERSION}
COMPILATION_FILES_DIR=${COMPILATION_FILES_DIR:-$INITIAL_DIR/additional-files/compilation}
BUILD_DIR=${BUILD_DIR:-$TARBALL_DIR/build}
RUN_BUILDOUT_DIR=${RUN_BUILDOUT_DIR:-$BUILD_DIR/$TARGET_DIR}
DISTRIB_FILES_DIR=${DISTRIB_FILES_DIR:-$INITIAL_DIR/additional-files/distributions}

### BUILDOUT FILES AND VERSIONS ###
GIT_REPOSITORY=${GIT_REPOSITORY:-https://lab.nexedi.com/nexedi/slapos}
GIT_BRANCH_OR_COMMIT=${GIT_BRANCH_OR_COMMIT:-master}
# This is the directory with the buildout files, it can be anything but it usually is a slapos repository.
BUILDOUT_DIR=${BUILDOUT_DIR:-$TARBALL_DIR/slapos_repository}
BUILDOUT_ENTRY_POINT=${BUILDOUT_ENTRY_POINT:-$BUILDOUT_DIR/software/$SOFTWARE_NAME/software.cfg}
## Versions
SETUPTOOLS_VERSION=${SETUPTOOLS_VERSION:-63.2.0}
ZC_BUILDOUT_VERSION=${ZC_BUILDOUT_VERSION:-2.7.1+slapos019}

### OBS INFORMATION ###
# Get the user from osc configuration file.
OBS_USER=${OBS_USER:-$(cat ~/.config/osc/oscrc | grep user= | cut -d'=' -f2)}
OBS_PROJECT=${OBS_PROJECT:-home:$OBS_USER}
OBS_DIR=${OBS_DIR:-$INITIAL_DIR/$OBS_PROJECT/$SOFTWARE_NAME}
# a prompt will be asked if empty
OBS_COMMIT_MSG=${OBS_COMMIT_MSG:-}


### MISCELLANEOUS ###

## Path normalization
INITIAL_DIR=$(realpath -m "$INITIAL_DIR")
TARGET_DIR=$(realpath -m "$TARGET_DIR")
TARBALL_DIR=$(realpath -m "$TARBALL_DIR")
BUILDOUT_DIR=$(realpath -m "$BUILDOUT_DIR")
BUILDOUT_ENTRY_POINT=$(realpath -m "$BUILDOUT_ENTRY_POINT")
COMPILATION_FILES_DIR=$(realpath -m "$COMPILATION_FILES_DIR")
BUILD_DIR=$(realpath -m "$BUILD_DIR")
RUN_BUILDOUT_DIR=$(realpath -m "$RUN_BUILDOUT_DIR")
DISTRIB_FILES_DIR=$(realpath -m "$DISTRIB_FILES_DIR")

## Regular expressions for templates
NAME_REGEX=${NAME_REGEX:-s|%SOFTWARE_NAME%|$SOFTWARE_NAME|g;s|%SOFTWARE_AND_VERSION%|$SOFTWARE_AND_VERSION|g}
VERSION_REGEX=${VERSION_REGEX:-s|%SOFTWARE_VERSION%|$SOFTWARE_VERSION|g;s|%DEBIAN_REVISION%|$DEBIAN_REVISION|g;s|%COMPOUND_VERSION%|$COMPOUND_VERSION|g}
DIR_REGEX=${DIR_REGEX:-s|%TARGET_DIR%|$TARGET_DIR|g;s|%BUILD_DIR%|$BUILD_DIR|g;s|%RUN_BUILDOUT_DIR%|$RUN_BUILDOUT_DIR|g}
PATH_REGEX=${PATH_REGEX:-s|%BUILDOUT_ENTRY_POINT%|$BUILDOUT_ENTRY_POINT|g}
ALL_REGEX=${ALL_REGEX:-$NAME_REGEX";"$VERSION_REGEX";"$DIR_REGEX";"$PATH_REGEX}
