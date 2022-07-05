#!/bin/bash
set -e

source build-scripts/00env.sh

cd "$INITIAL_DIR"
### Retrieve the buildout directory.
# Note: This is usually a slapos git repository but it can be otherwise.
# There needs to be at least one buildout file to point to (the entry point) which can extend other build files. See the buildout documentation if this is unclear.
mkdir -p "$TARBALL_DIR"
git clone https://lab.nexedi.com/Ophelie/slapos "$BUILDOUT_DIR"
cd "$BUILDOUT_DIR"
git checkout metadata-collect-agent
# example with a local copy of the buildout directory: 
#cp -r /home/test/other-projects/model/mca.my-slapos "$BUILDOUT_DIR"

cd "$INITIAL_DIR"
### Peparing the build directories
mkdir -p "$RUN_BUILDOUT_DIR"/{eggs,extends-cache,download-cache/dist}
