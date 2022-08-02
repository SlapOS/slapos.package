####################################################
# Used in build-scripts/00env.sh: source lunzip_env.sh
####################################################

MAINTAINER_NAME="Ophelie"
MAINTAINER_EMAIL="ophelie.gagnard@nexedi.com"
CURRENT_DATE="$(date -R)"

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
SETUPTOOLS_VERSION=44.1.1
ZC_BUILDOUT_VERSION=2.7.1+slapos016
ZC_RECIPE_EGG_VERSION=2.0.3+slapos003
