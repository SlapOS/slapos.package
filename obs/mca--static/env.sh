export MAINTAINER_NAME="Ophélie Gagnard"
export MAINTAINER_EMAIL=ophelie.gagnard@nexedi.com

export SOFTWARE_NAME=mca--static
# version format: <mca>+<slapos>
export SOFTWARE_VERSION=0.3.1

export PACKAGE_BUILD_DEPENDENCIES="debhelper (>= 4.1.16), chrpath, wget, python3 (>= 3.7) | python, python3-dev (>= 3.7) | python-dev"
export BUILDOUT_RELATIVE_PATH=component/mca/obs-static.cfg

export OBS_PROJECT=home:oph.nxd
export OBS_COMMIT_MSG="Yet another push in OBS."
