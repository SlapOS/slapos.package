####################################################
# Sourced in build-scripts/00variable-management.sh
####################################################

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
ROLE_IN_SLAPOS=component
CFG_NAME=buildout.cfg
SETUPTOOLS_VERSION=44.1.1
ZC_BUILDOUT_VERSION=2.7.1+slapos016
