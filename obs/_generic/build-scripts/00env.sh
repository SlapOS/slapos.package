####################################################
# Sourced in build-scripts/00variable-management.sh
####################################################

### The user MUST define the following variables
# SOFTWARE_NAME -> the name of the software, which is the directory in obs/
# MAINTAINER_NAME
# MAINTAINER_EMAIL
# OBS_USER

### The user CAN define the following variables
## Debian packaging information
SOFTWARE_VERSION=${SOFTWARE_VERSION:-1}
DEBIAN_REVISION=${DEBIAN_REVISINO:-1}
# For the version format, see: https://www.debian.org/doc/manuals/debian-faq/pkg-basics.en.html#pkgname
# here, in <foo>_<VersionNumber>-<DebianRevisionNumber>_<DebianArchitecture>.deb
# VersionNumber is SOFTWARE_VERSION, DebianRevisionNumber is DEBIAN_REVISION
# note: the architecture is added when building the package (here: in OBS)
COMPOUND_VERSION=${COMPOUND_VERSION:-${SOFTWARE_VERSION}-${DEBIAN_REVISION}}
SOFTWARE_AND_VERSION=${SOFTWARE_AND_VERSION:-${SOFTWARE_NAME}_${COMPOUND_VERSION}}
# This is the directory you want your package to install your software in.
# Use "/" for building an official distribution package.
TARGET_DIR="${TARGET_DIR:-/opt/$SOFTWARE_AND_VERSION}"
## Distribution information
# Source package
PACKAGE_SECTION=${PACKAGE_SECTION:-utils}
PACKAGE_PRIORITY=${PACKAGE_PRIORITY:-optional}
PACKAGE_BUILD_DEPENDENCIES=${PACKAGE_BUILD_DEPENDENCIES:-debhelper (>= 4.1.16), chrpath, python (>= 2.7),}
# Binary package
PACKAGE_ARCHITECTURE=${PACKAGE_ARCHITECTURE:-any}
PACKAGE_DEPENDENCIES=${PACKAGE_DEPENDENCIES:-\$\{misc:Depends\}, \$\{shlibs:Depends\},}
PACKAGE_CONFICTS=${PACKAGE_CONFLICTS:-}
PACKAGE_SHORT_DESCRIPTION=${PACKAGE_SHORT_DESCRIPTION:-Package for ${SOFTWARE_NAME}.}
# Changelog
PACKAGE_DISTRIBUTION_VALUE=${PACKAGE_DISTRIBUTION_VALUE:-UNRELEASED}
PACKAGE_URGENCY=${PACKAGE_URGENCY:-medium}
PACKAGE_CHANGE_DETAILS=${PACKAGE_CHANGELOG_TEXT:-* Initial release. (Closes: #XXXXXX)}
# Miscelaneous
PACKAGE_DIRECTORIES=${PACKAGE_DIRECTORIES:-/opt/$SOFTWARE_AND_VERSION}
## Buildout file and version
GIT_REPOSITORY=${GIT_REPOSITORY:-https://lab.nexedi.com/nexedi/slapos}
GIT_BRANCH_OR_COMMIT=${GIT_BRANCH_OR_COMMIT:-master}
BUILDOUT_RELATIVE_PATH=${BUILDOUT_RELATIVE_PATH:-software/$SOFTWARE_NAME/software.cfg}
## Versions
SETUPTOOLS_VERSION=${SETUPTOOLS_VERSION:-63.2.0}
ZC_BUILDOUT_VERSION=${ZC_BUILDOUT_VERSION:-2.7.1+slapos019}
## OBS information
# Get the user from osc configuration file.
OBS_PROJECT=${OBS_PROJECT:-home:$OBS_USER}
OBS_PACKAGE=${OBS_PACKAGE:-$SOFTWARE_NAME}
# a prompt will be asked if empty
OBS_COMMIT_MSG=${OBS_COMMIT_MSG:-}

### The user CANNOT define the following variables
CURRENT_DATE="$(date -R)"
ARCHIVE_EXT=.tar.gz
INITIAL_DIR=$(pwd)
TARBALL_DIR="$INITIAL_DIR/_tarballs/$SOFTWARE_AND_VERSION"
COMPILATION_FILES_GENERIC_DIR="$INITIAL_DIR/_generic/compilation"
COMPILATION_FILES_SOFTWARE_DIR="$INITIAL_DIR/$SOFTWARE_NAME/compilation"
BUILD_DIR="$TARBALL_DIR/build"
RUN_BUILDOUT_DIR="$BUILD_DIR/$TARGET_DIR"
DISTRIB_FILES_GENERIC_DIR="$INITIAL_DIR/_generic/distributions"
DISTRIB_FILES_SOFTWARE_DIR="$INITIAL_DIR/$SOFTWARE_NAME/distributions"
BUILDOUT_DIR="$TARBALL_DIR/slapos_repository"
BUILDOUT_ENTRY_POINT="$BUILDOUT_DIR/$BUILDOUT_RELATIVE_PATH"
OBS_DIR="$INITIAL_DIR/$OBS_PROJECT/$OBS_PACKAGE"

## Path normalization
INITIAL_DIR=$(realpath -m "$INITIAL_DIR")
TARGET_DIR=$(realpath -m "$TARGET_DIR")
TARBALL_DIR=$(realpath -m "$TARBALL_DIR")
BUILDOUT_DIR=$(realpath -m "$BUILDOUT_DIR")
BUILDOUT_ENTRY_POINT=$(realpath -m "$BUILDOUT_ENTRY_POINT")
COMPILATION_FILES_GENERIC_DIR=$(realpath -m "$COMPILATION_FILES_GENERIC_DIR")
COMPILATION_FILES_SOFTWARE_DIR=$(realpath -m "$COMPILATION_FILES_SOFTWARE_DIR")
BUILD_DIR=$(realpath -m "$BUILD_DIR")
RUN_BUILDOUT_DIR=$(realpath -m "$RUN_BUILDOUT_DIR")
DISTRIB_FILES_GENERIC_DIR=$(realpath -m "$DISTRIB_FILES_GENERIC_DIR")
DISTRIB_FILES_SOFTWARE_DIR=$(realpath -m "$DISTRIB_FILES_SOFTWARE_DIR")

## Regular expressions for templates
NAME_REGEX="s|%SOFTWARE_NAME%|$SOFTWARE_NAME|g;s|%SOFTWARE_AND_VERSION%|$SOFTWARE_AND_VERSION|g"
VERSION_REGEX="s|%SOFTWARE_VERSION%|$SOFTWARE_VERSION|g;s|%DEBIAN_REVISION%|$DEBIAN_REVISION|g;s|%COMPOUND_VERSION%|$COMPOUND_VERSION|g"
BUILDOUT_REGEX="s|%SETUPTOOLS_VERSION%|$SETUPTOOLS_VERSION|g;s|%ZC_BUILDOUT_VERSION%|$ZC_BUILDOUT_VERSION|g;s|%ZC_RECIPE_EGG_VERSION%|$ZC_RECIPE_EGG_VERSION|g"
DIR_REGEX="s|%TARGET_DIR%|$TARGET_DIR|g;s|%BUILD_DIR%|$BUILD_DIR|g;s|%RUN_BUILDOUT_DIR%|$RUN_BUILDOUT_DIR|g"
PATH_REGEX="s|%BUILDOUT_ENTRY_POINT%|$BUILDOUT_ENTRY_POINT|g"
DISTRIB_REGEX="s|%MAINTAINER_NAME%|$MAINTAINER_NAME|g;s|%MAINTAINER_EMAIL%|$MAINTAINER_EMAIL|g;s|%CURRENT_DATE%|$CURRENT_DATE|g;s|%PACKAGE_SECTION%|$PACKAGE_SECTION|g;s|%PACKAGE_PRIORITY%|$PACKAGE_PRIORITY|g;s|%PACKAGE_BUILD_DEPENDENCIES%|$PACKAGE_BUILD_DEPENDENCIES|g;s|%PACKAGE_ARCHITECTURE%|$PACKAGE_ARCHITECTURE|g;s|%PACKAGE_DEPENDENCIES%|$PACKAGE_DEPENDENCIES|g;s|%PACKAGE_CONFLICTS%|$PACKAGE_CONFLICTS|g;s|%PACKAGE_SHORT_DESCRIPTION%|$PACKAGE_SHORT_DESCRIPTION|g;s|%PACKAGE_DISTRIBUTION_VALUE%|$PACKAGE_DISTRIBUTION_VALUE|g;s|%PACKAGE_URGENCY%|$PACKAGE_URGENCY|g;s|%PACKAGE_CHANGE_DETAILS%|$PACKAGE_CHANGE_DETAILS|g;s|%PACKAGE_DIRECTORIES%|$PACKAGE_DIRECTORIES|g"
ALL_REGEX=$NAME_REGEX";"$VERSION_REGEX";"$BUILDOUT_REGEX";"$DIR_REGEX";"$PATH_REGEX";"$DISTRIB_REGEX

copy_additional_files () {
	# Take 2 directories' path as arguments: source and target.
	# Copy every subdirectory of source in target and fill it with
	# transformed templates and non-template files. Every file with
	# .in extension is considered a template.
	
	if [ ! -d "$1" ]; then
		echo "Directory does not exist, returning."
		echo "$1"
		return
	fi

	echo "------------------------------------"
	echo "Copy additional files from $1 to $2"
	echo

	echo "Create corresponding subdirectories."
	for directory in $(find "$1"/ -type d); do
		subdirectory_name="${directory##$1/}"
		mkdir -vp $2/"$subdirectory_name"
	done

	echo "Use template files."
	for template in $(find "$1" -name "*.in" -type f); do
		template_name="${template##$1/}"
		echo "Creating $2/${template_name%.in} from $template"
		sed "$ALL_REGEX" "$template" > "$2/${template_name%.in}"
	done

	echo "Copy non-template files."
	for file in $(find "$1" -not -name "*.in" -type f); do
		file_name="${file##$1/}"
		cp -v "$file" "$2/$file_name"
	done

	echo "Copied additional files from $1 to $2"
	echo "------------------------------------"
}
