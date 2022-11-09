# package containing fluent-bit

export MAINTAINER_NAME="Ophélie Gagnard"
export MAINTAINER_EMAIL=ophelie.gagnard@nexedi.com

export SOFTWARE_NAME=fluent-bit
# version format: <fluent-bit>+<slapos>
export SOFTWARE_VERSION=1.9.7+1.0.279+dep
export GIT_BRANCH_OR_COMMIT=1.0.279

export PACKAGE_BUILD_DEPENDENCIES="debhelper (>= 4.1.16), chrpath, wget, python (>= 2.7), python3 (>= 3.7), python3-dev (>= 3.7), golang (>= 2:1.15~1), cmake (>= 3.18)"
export GIT_REPOSITORY=https://lab.nexedi.com/Ophelie/slapos.git
export GIT_BRANCH_OR_COMMIT=fluent-bit_tmp
export BUILDOUT_RELATIVE_PATH=component/fluent-bit/dep--fluent-bit.cfg
export ZC_BUILDOUT_VERSION=2.7.1+slapos019

export OBS_COMMIT_MSG="Yet another push in OBS."
