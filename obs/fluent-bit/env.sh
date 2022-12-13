# package containing fluent-bit

export MAINTAINER_NAME="Ophélie Gagnard"
export MAINTAINER_EMAIL=ophelie.gagnard@nexedi.com

export SOFTWARE_NAME=fluent-bit
# version format: <fluent-bit>+<slapos>
export SOFTWARE_VERSION=1.9.8

export PACKAGE_BUILD_DEPENDENCIES="debhelper (>= 4.1.16), chrpath, wget, python3 (>= 3.7) | python, python3-dev (>= 3.7) | python-dev"
export BUILDOUT_RELATIVE_PATH=component/fluent-bit/obs.cfg
export ZC_BUILDOUT_VERSION=2.7.1+slapos019

export OBS_PROJECT=home:oph.nxd
export OBS_COMMIT_MSG="Yet another push in OBS."
