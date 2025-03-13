# package containing fluent-bit

export MAINTAINER_NAME="Thomas Gambier"
export MAINTAINER_EMAIL=thomas.gambier@nexedi.com

export SOFTWARE_NAME=fluent-bit
# version format: <fluent-bit>+<slapos>
export SOFTWARE_VERSION=2.1.10

export PACKAGE_BUILD_DEPENDENCIES="debhelper (>= 4.1.16), chrpath, wget, python3 (>= 3.7) | python, python3-dev (>= 3.7) | python-dev"
export BUILDOUT_RELATIVE_PATH=component/fluent-bit/obs.cfg

export OBS_PROJECT=home:VIFIBnexedi:branches:home:VIFIBnexedi
export OBS_COMMIT_MSG="Yet another push in OBS."
