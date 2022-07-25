#!/bin/bash

set -e

source compilation-env.sh

echo "Fixing buildout path to $(TARBALL_DIR) rather than $(OLD_TARBALL_DIR) for buildout"
cd "$(RUN_BUILDOUT_DIR)"; sed -i 's#$(OLD_TARBALL_DIR)#$(TARBALL_DIR)#g' buildout.cfg bin/*
cd "$(RUN_BUILDOUT_DIR)" && $(PY) ./bin/buildout -v

touch build-stamp
