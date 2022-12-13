####################################################
# Sourced in 10tarball_directory.sh and 20obs.sh
####################################################

### The user MUST define the following variables
# SOFTWARE_NAME -> the name of the software, which is the directory in obs/
# MAINTAINER_NAME
# MAINTAINER_EMAIL

### The user CAN define the following variables
## Debian packaging information
SOFTWARE_VERSION=${SOFTWARE_VERSION:-1}
DEBIAN_REVISION=${DEBIAN_REVISION:-1}
# For the version format, see: https://www.debian.org/doc/manuals/debian-faq/pkg-basics.en.html#pkgname
# here, in <foo>_<VersionNumber>-<DebianRevisionNumber>_<DebianArchitecture>.deb
# VersionNumber is SOFTWARE_VERSION, DebianRevisionNumber is DEBIAN_REVISION
# note: the architecture is added when building the package (here: in OBS)
COMPOUND_VERSION=${COMPOUND_VERSION:-${SOFTWARE_VERSION}-${DEBIAN_REVISION}}
# This is the directory you want your package to install your software in.
# Use "/" for building an official distribution package.
TARGET_DIR="${TARGET_DIR:-/opt/$SOFTWARE_NAME}"
TARGET_DIR=$(realpath -m "$TARGET_DIR")
## Distribution information
# Source package
PACKAGE_SECTION=${PACKAGE_SECTION:-utils}
PACKAGE_PRIORITY=${PACKAGE_PRIORITY:-optional}
PACKAGE_BUILD_DEPENDENCIES=${PACKAGE_BUILD_DEPENDENCIES:-debhelper, chrpath, python3 (>= 3.7) | python, python3-dev (>= 3.7) | python-dev}
# Binary package
PACKAGE_ARCHITECTURE=${PACKAGE_ARCHITECTURE:-any}
PACKAGE_DEPENDENCIES=${PACKAGE_DEPENDENCIES:-\$\{misc:Depends\}, \$\{shlibs:Depends\},}
PACKAGE_CONFLICTS=${PACKAGE_CONFLICTS:-}
PACKAGE_SHORT_DESCRIPTION=${PACKAGE_SHORT_DESCRIPTION:-Package for ${SOFTWARE_NAME}.}
# Changelog
PACKAGE_DISTRIBUTION_VALUE=${PACKAGE_DISTRIBUTION_VALUE:-UNRELEASED}
PACKAGE_URGENCY=${PACKAGE_URGENCY:-medium}
## Buildout file and version
GIT_REPOSITORY=${GIT_REPOSITORY:-https://lab.nexedi.com/nexedi/slapos.git}
GIT_BRANCH_OR_COMMIT=${GIT_BRANCH_OR_COMMIT:-master}
BUILDOUT_RELATIVE_PATH=${BUILDOUT_RELATIVE_PATH:-software/$SOFTWARE_NAME/software.cfg}
## OBS information
OBS_PROJECT=${OBS_PROJECT:-home:VIFIBnexedi:branches:home:VIFIBnexedi}
OBS_PACKAGE=${OBS_PACKAGE:-$SOFTWARE_NAME}
# OBS_COMMIT_MSG can be used, a prompt will be asked if empty or undefined

### The user CANNOT define the following variables
CURRENT_DATE="$(date -R)"
SOFTWARE_AND_VERSION="${SOFTWARE_NAME}_${COMPOUND_VERSION}"
ARCHIVE_EXT=.tar.gz
INITIAL_DIR=$(pwd)
TARBALL_DIR="$INITIAL_DIR/_tarballs/$SOFTWARE_AND_VERSION"
COMPILATION_FILES_GENERIC_DIR="$INITIAL_DIR/_generic/compilation"
COMPILATION_FILES_SOFTWARE_DIR="$INITIAL_DIR/$SOFTWARE_NAME/compilation"
BUILD_DIR="$TARBALL_DIR/build"
RUN_BUILDOUT_DIR="$BUILD_DIR/$TARGET_DIR"
## Versions
# OLD_SETUPTOOLS_VERSION must be strictly older than SETUPTOOLS_VERSION
OLD_SETUPTOOLS_VERSION=44.1.0
SETUPTOOLS_VERSION=44.1.1
ZC_BUILDOUT_VERSION=2.7.1+slapos019
ZC_RECIPE_EGG_VERSION=2.0.3+slapos003
SLAPOS_LIBNETWORKCACHE_VERSION=0.25
DISTRIB_FILES_GENERIC_DIR="$INITIAL_DIR/_generic/distributions"
DISTRIB_FILES_SOFTWARE_DIR="$INITIAL_DIR/$SOFTWARE_NAME/distributions"
BUILDOUT_DIR="$TARBALL_DIR/slapos_repository"
BUILDOUT_ENTRY_POINT="$BUILDOUT_DIR/$BUILDOUT_RELATIVE_PATH"
BUILDOUT_ENTRY_POINT=$(realpath -m "$BUILDOUT_ENTRY_POINT")
OBS_DIR="$INITIAL_DIR/$OBS_PROJECT/$OBS_PACKAGE"

## Regular expressions for templates
NAME_REGEX="s#%SOFTWARE_NAME%#$SOFTWARE_NAME#g;s#%SOFTWARE_AND_VERSION%#$SOFTWARE_AND_VERSION#g"
VERSION_REGEX="s#%SOFTWARE_VERSION%#$SOFTWARE_VERSION#g;s#%DEBIAN_REVISION%#$DEBIAN_REVISION#g;s#%COMPOUND_VERSION%#$COMPOUND_VERSION#g"
BUILDOUT_REGEX="s#%SETUPTOOLS_VERSION%#$SETUPTOOLS_VERSION#g;s#%ZC_BUILDOUT_VERSION%#$ZC_BUILDOUT_VERSION#g;s#%ZC_RECIPE_EGG_VERSION%#$ZC_RECIPE_EGG_VERSION#g;s#%SLAPOS_LIBNETWORKCACHE%#$SLAPOS_LIBNETWORKCACHE#g"
DIR_REGEX="s#%TARGET_DIR%#$TARGET_DIR#g;s#%BUILD_DIR%#$BUILD_DIR#g;s#%RUN_BUILDOUT_DIR%#$RUN_BUILDOUT_DIR#g"
PATH_REGEX="s#%BUILDOUT_ENTRY_POINT%#$BUILDOUT_ENTRY_POINT#g"
DISTRIB_REGEX="s#%MAINTAINER_NAME%#$MAINTAINER_NAME#g;s#%MAINTAINER_EMAIL%#$MAINTAINER_EMAIL#g;s#%CURRENT_DATE%#$CURRENT_DATE#g;s#%PACKAGE_SECTION%#$PACKAGE_SECTION#g;s#%PACKAGE_PRIORITY%#$PACKAGE_PRIORITY#g;s#%PACKAGE_BUILD_DEPENDENCIES%#$PACKAGE_BUILD_DEPENDENCIES#g;s#%PACKAGE_ARCHITECTURE%#$PACKAGE_ARCHITECTURE#g;s#%PACKAGE_DEPENDENCIES%#$PACKAGE_DEPENDENCIES#g;s#%PACKAGE_CONFLICTS%#$PACKAGE_CONFLICTS#g;s#%PACKAGE_SHORT_DESCRIPTION%#$PACKAGE_SHORT_DESCRIPTION#g;s#%PACKAGE_DISTRIBUTION_VALUE%#$PACKAGE_DISTRIBUTION_VALUE#g;s#%PACKAGE_URGENCY%#$PACKAGE_URGENCY#g;s#%PACKAGE_CHANGE_DETAILS%#$PACKAGE_CHANGE_DETAILS#g;s#%PACKAGE_DIRECTORIES%#$PACKAGE_DIRECTORIES#g"
ALL_REGEX=$NAME_REGEX";"$VERSION_REGEX";"$BUILDOUT_REGEX";"$DIR_REGEX";"$PATH_REGEX";"$DISTRIB_REGEX

copy_and_solve_templates () {
	if [ ! -d "$1" ]; then
		echo "INFO: copy_and_solve_templates(): The source directory does not exist, returning."
		echo "$1"
		return 0
	elif [ ! -d "$2" ]; then
		echo "ERROR: copy_and_solve_templates(): The target directory does not exist, returning."
		echo "$2"
		return 1
	fi

	for descriptor in "$1"/*; do
		cp -r "$descriptor" "$2"
		for template_path in $(find "$2/${descriptor##$1/}" -name *.in -type f); do
			sed "$ALL_REGEX" "$template_path" > "${template_path%.in}"
			rm "$template_path"
		done
	done
}
