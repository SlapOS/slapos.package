#!/bin/bash

set -e

echo "Fixing buildout path to "$TARBALL_DIR" rather than "$OLD_TARBALL_DIR" for buildout"
cd "$RUN_BUILDOUT_DIR"; sed -i 's#$(OLD_TARBALL_DIR)#$(TARBALL_DIR)#g' buildout.cfg bin/*
echo RUN_BUILDOUT_DIR = "$RUN_BUILDOUT_DIR" \; PY = "$PY"
cd "$RUN_BUILDOUT_DIR" && "$PY" ./bin/buildout -v
