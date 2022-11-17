export MAINTAINER_NAME="Ophélie Gagnard"
export MAINTAINER_EMAIL=ophelie.gagnard@nexedi.com

export SOFTWARE_NAME=mca--static
# version format: <mca>+<fluentbit-plugin>+<slapos>
export SOFTWARE_VERSION=0.3.1+1.0.293+nodep

export PACKAGE_BUILD_DEPENDENCIES="debhelper (>= 4.1.16), chrpath, wget, python (>= 2.7), python3 (>= 3.7), python3-dev (>= 3.7), cmake (>= 3.18)"
export BUILDOUT_RELATIVE_PATH=component/mca/obs-static-nodep.cfg

export OBS_PROJECT=home:oph.nxd
export OBS_COMMIT_MSG="Yet another push in OBS."
