export MAINTAINER_NAME="Ophélie Gagnard"
export MAINTAINER_EMAIL=ophelie.gagnard@nexedi.com

export SOFTWARE_NAME=mca--static
# version format: <mca>+<fluentbit-plugin>+<slapos>
export SOFTWARE_VERSION=0.2h+0.1i+1.0.277
export GIT_BRANCH_OR_COMMIT=1.0.277

export PACKAGE_BUILD_DEPENDENCIES="debhelper (>= 4.1.16), chrpath, wget, python (>= 2.7), python3 (>= 3.7), python3-dev (>= 3.7), golang (>= 2:1.15~1), cmake (>= 3.18)"
export BUILDOUT_RELATIVE_PATH=software/mca/dep--mca--static.cfg
export SETUPTOOLS_VERSION=44.1.1
export ZC_BUILDOUT_VERSION=2.7.1+slapos019
