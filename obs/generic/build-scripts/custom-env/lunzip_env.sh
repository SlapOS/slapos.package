####################################################
# Used in build-scripts/00env.sh: source lunzip_env.sh
####################################################

MAINTAINER_NAME="Ophelie"
MAINTAINER_EMAIL="ophelie.gagnard@nexedi.com"

### DEBIAN_REVISION INFORMATION ###
# Modify the following variables accordingly
SOFTWARE_VERSION=1
DEBIAN_REVISION=1
SOFTWARE_NAME=lunzip

### INSTALL INFORMATION ###
# This is the directory you want your package to install your software in.
# Use "/" for building an official distribution package.
TARGET_DIR="/"

### BUILDOUT FILES AND VERSIONS ###
BUILDOUT_ENTRY_POINT="$(pwd)/tarballs/${SOFTWARE_NAME}_${SOFTWARE_VERSION}-${DEBIAN_REVISION}/slapos_repository/component/$SOFTWARE_NAME/buildout.cfg"
SETUPTOOLS_VERSION=44.1.1
ZC_BUILDOUT_VERSION=2.7.1+slapos016
