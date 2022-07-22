####################################################
# Use on script as source release_configuration.sh
####################################################

INITIAL_DIR=$(pwd)/
INITIAL_DIR=$(realpath -m "$INITIAL_DIR")

### DEBIAN_REVISION INFORMATION ###
SOFTWARE_VERSION=1
DEBIAN_REVISION=1
SOFTWARE_NAME=lunzip

# For the version format, see: https://www.debian.org/doc/manuals/debian-faq/pkg-basics.en.html#pkgname
# here, in <foo>_<VersionNumber>-<DebianRevisionNumber>_<DebianArchitecture>.deb
# VersionNumber is SOFTWARE_VERSION, DebianRevisionNumber is DEBIAN_REVISION
# note: the architecture is added when building the package (here: in OBS)
COMPOUND_VERSION="${SOFTWARE_VERSION}-${DEBIAN_REVISION}"
SOFTWARE_AND_VERSION="${SOFTWARE_NAME}_${COMPOUND_VERSION}"
ARCHIVE_EXT=.tar.gz

### INSTALL INFORMATION ###
# This is the directory you want your package to install your software in.
# Use "/" for building an official distribution package.
TARGET_DIR="/"

### BUILD INFORMATION ###
# This is the directory with the buildout files, it can be anything but it usually is a slapos repository.
TARBALL_DIR="$INITIAL_DIR/tarballs/$SOFTWARE_AND_VERSION"
COMPILATION_FILES_DIR="$INITIAL_DIR/additional-files/compilation"
BUILD_DIR="$TARBALL_DIR/build"
RUN_BUILDOUT_DIR="$BUILD_DIR/$TARGET_DIR"

### BUILDOUT FILES AND VERSIONS ###
GIT_REPOSITORY=https://lab.nexedi.com/nexedi/slapos
GIT_BRANCH_OR_COMMIT=master
BUILDOUT_DIR="$TARBALL_DIR/slapos_repository"
BUILDOUT_ENTRY_POINT="$BUILDOUT_DIR/component/$SOFTWARE_NAME/buildout.cfg"
## Versions
SETUPTOOLS_VERSION=44.1.1
ZC_BUILDOUT_VERSION=2.7.1+slapos016


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

## Regular expressions for templates
NAME_REGEX="s|%SOFTWARE_NAME%|$SOFTWARE_NAME|g;s|%SOFTWARE_AND_VERSION%|$SOFTWARE_AND_VERSION|g"
VERSION_REGEX="s|%SOFTWARE_VERSION%|$SOFTWARE_VERSION|g;s|%DEBIAN_REVISION%|$DEBIAN_REVISION|g;s|%COMPOUND_VERSION%|$COMPOUND_VERSION|g"
DIR_REGEX="s|%TARGET_DIR%|$TARGET_DIR|g;s|%BUILD_DIR%|$BUILD_DIR|g;s|%RUN_BUILDOUT_DIR%|$RUN_BUILDOUT_DIR|g"
PATH_REGEX="s|%BUILDOUT_ENTRY_POINT%|$BUILDOUT_ENTRY_POINT|g"
ALL_REGEX="$NAME_REGEX;$VERSION_REGEX;$DIR_REGEX;$PATH_REGEX"
