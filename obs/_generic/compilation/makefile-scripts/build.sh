#!/bin/bash

set -e

source makefile-scripts/compilation-env.sh

echo "Fixing buildout path to "$TARBALL_DIR" rather than "$OLD_TARBALL_DIR" for buildout"
cd "$RUN_BUILDOUT_DIR"
sed -i "s#$OLD_TARBALL_DIR#$TARBALL_DIR#g" buildout.cfg bin/*
bin/buildout -v

touch clean-stamp
