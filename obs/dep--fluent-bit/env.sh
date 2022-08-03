####################################################
# Sourced in build-scripts/00variable-management.sh
####################################################

MAINTAINER_NAME=Ophelie
MAINTAINER_EMAIL=ophelie.gagnard@nexedi.com

### DEBIAN_REVISION INFORMATION ###
# Modify the following variables accordingly
SOFTWARE_VERSION=1
DEBIAN_REVISION=1
SOFTWARE_NAME=dep--fluent-bit

### DISTRIBUTIONS INFORMATION ###
PACKAGE_BUILD_DEPENDENCIES="debhelper (>= 4.1.16), chrpath, wget, python (>= 2.7), python3 (>= 3.7), python3-dev (>= 3.7), cmake (>= 3.18)"

### BUILDOUT FILES AND VERSIONS ###
GIT_REPOSITORY=https://lab.nexedi.com/Ophelie/slapos
GIT_BRANCH_OR_COMMIT=metadata-collect-agent
SETUPTOOLS_VERSION=44.1.1
ZC_BUILDOUT_VERSION=2.7.1+slapos016
