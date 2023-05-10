export MAINTAINER_NAME="Xiaowu Zhang"
export MAINTAINER_EMAIL=xiaowu.zhang@nexedi.com

export SOFTWARE_NAME=plugin-fluentbit-to-wendelin
# version format: <fluentbit-plugin>+<slapos>
# nodep means "no build dependencies"
export SOFTWARE_VERSION=0.3.3

export PACKAGE_BUILD_DEPENDENCIES="debhelper (>= 4.1.16), chrpath, wget, python (>= 2.7), python3 (>= 3.7), python3-dev (>= 3.7), golang (>= 2:1.15~1)"
export BUILDOUT_RELATIVE_PATH=component/fluentbit-plugin-wendelin/obs-nodep.cfg

export OBS_PROJECT=home:xiaowu
export OBS_COMMIT_MSG="Yet another push in OBS."
