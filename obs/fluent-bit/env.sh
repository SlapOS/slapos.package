# packahge containing fluent-bit

export MAINTAINER_NAME="Ophélie Gagnard"
export MAINTAINER_EMAIL=ophelie.gagnard@nexedi.com

export SOFTWARE_NAME=fluent-bit
# version format: <fluent-bit>+<slapos>
export SOFTWARE_VERSION=1.9.7+1.0.277
export GIT_BRANCH_OR_COMMIT=1.0.277

export PACKAGE_BUILD_DEPENDENCIES="debhelper (>= 4.1.16), chrpath, wget, python (>= 2.7), python3 (>= 3.7), python3-dev (>= 3.7), cmake (>= 3.18)"
export SETUPTOOLS_VERSION=44.1.1
export ZC_BUILDOUT_VERSION=2.7.1+slapos019
