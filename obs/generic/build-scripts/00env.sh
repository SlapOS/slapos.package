####################################################
# Use on script as source release_configuration.sh
####################################################

INITIAL_DIR=$(pwd)/
INITIAL_DIR=$(realpath -m "$INITIAL_DIR")

source "$INITIAL_DIR"/build-scripts/custom-env/"${NAME}"_env.sh

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

### BUILDOUT FILES AND VERSIONS ###
GIT_REPOSITORY=${GIT_REPOSITORY:-https://lab.nexedi.com/nexedi/slapos}
GIT_BRANCH_OR_COMMIT=${GIT_BRANCH_OR_COMMIT:-master}

SETUPTOOLS_VERSION=${SETUPTOOLS_VERSION:-63.2.0}
ZC_BUILDOUT_VERSION=${ZC_BUILDOUT_VERSION:-2.7.1+slapos019}
ZC_RECIPE_EGG_VERSION=${ZC_RECIPE_EGG_VERSION:-2.0.3+slapos003}

### OBS AND DISTRIBUTIONS INFORMATION ###
# Get the user from osc configuration file.
OBS_USER=${OBS_USER:-$(cat ~/.config/osc/oscrc | grep user= | cut -d'=' -f2)}
OBS_PROJECT=${OBS_PROJECT:-home:$OBS_USER}
OBS_DIR=${OBS_DIR:-$INITIAL_DIR/$OBS_PROJECT/$SOFTWARE_NAME/}
DIST_DIR=${DIST_DIR:-$INITIAL_DIR/distribution-specifics/$SOFTWARE_NAME/}
TARBALL_DIR=${TARBALL_DIR:-$INITIAL_DIR/tarballs/$SOFTWARE_AND_VERSION}

### BUILD INFORMATION ###
# This is the directory with the buildout files, it can be anything but it usually is a slapos repository.
BUILDOUT_DIR=${BUILDOUT_DIR:-$TARBALL_DIR/slapos_repository/}
BUILDOUT_ENTRY_POINT=${BUILDOUT_ENTRY_POINT:-$BUILDOUT_DIR/component/$SOFTWARE_NAME/buildout.cfg}

COMPILATION_FILES_DIR=${COMPILATION_FILES_DIR:-$INITIAL_DIR/additional-files/compilation}
BUILD_DIR=${BUILD_DIR:-$TARBALL_DIR/build/}
RUN_BUILDOUT_DIR=${RUN_BUILDOUT_DIR:-$BUILD_DIR/$TARGET_DIR}
DISTRIB_FILES_DIR=${DISTRIB_FILES_DIR:-$INITIAL_DIR/additional-files/distirbution}


## Path normalization
INITIAL_DIR=$(realpath -m "$INITIAL_DIR")
TARGET_DIR=$(realpath -m "$TARGET_DIR")
OBS_DIR=$(realpath -m "$OBS_DIR")
DIST_DIR=$(realpath -m "$DIST_DIR")
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
BUILDOUT_REGEX=${BUILDOUT_REGEX:-s|%SETUPTOOLS_VERSION%|$SETUPTOOLS_VERSION|g;s|%ZC_BUILDOUT_VERSION%|$ZC_BUILDOUT_VERSION|g;s|%ZC_RECIPE_EGG_VERSION%|$ZC_RECIPE_EGG_VERSION|g}
DIR_REGEX=${DIR_REGEX:-s|%TARGET_DIR%|$TARGET_DIR|g;s|%BUILD_DIR%|$BUILD_DIR|g;s|%RUN_BUILDOUT_DIR%|$RUN_BUILDOUT_DIR|g}
PATH_REGEX=${PATH_REGEX:-s|%BUILDOUT_ENTRY_POINT%|$BUILDOUT_ENTRY_POINT|g}
ALL_REGEX=${ALL_REGEX:-$NAME_REGEX";"$VERSION_REGEX";"$BUILDOUT_REGEX";"$DIR_REGEX";"$PATH_REGEX}

### FUNCTIONS ###
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
	for directory in $(find "$1" -type d); do
		subdirectory_name="${directory##$1/}"
		mkdir -vp $2/"$directory_name"
	done

	echo "Use template files."
	for template in $(find "$1" -name "*.in"); do
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
