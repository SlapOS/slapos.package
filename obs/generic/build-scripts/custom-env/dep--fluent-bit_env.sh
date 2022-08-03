####################################################
# Used in build-scripts/00env.sh: source lunzip_env.sh
####################################################

MAINTAINER_NAME=Ophelie
MAINTAINER_EMAIL=ophelie.gagnard@nexedi.com
CURRENT_DATE="$(date -R)"

### DEBIAN_REVISION INFORMATION ###
# Modify the following variables accordingly
SOFTWARE_VERSION=1
DEBIAN_REVISION=1
SOFTWARE_NAME=dep--fluent-bit

### BUILDOUT FILES AND VERSIONS ###
GIT_REPOSITORY=https://lab.nexedi.com/Ophelie/slapos
GIT_BRANCH_OR_COMMIT=metadata-collect-agent
SETUPTOOLS_VERSION=44.1.1
ZC_BUILDOUT_VERSION=2.7.1+slapos016

### OBS AND DISTRIBUTIONS INFORMATION ###
OBS_COMMIT_MSG="Test dep--fluent-bit"
