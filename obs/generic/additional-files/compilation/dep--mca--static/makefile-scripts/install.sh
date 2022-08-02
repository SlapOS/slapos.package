#!/bin/bash

set -e

source makefile-scripts/compilation-env.sh

# note: /share files such as manpages are not yet supported in this project
mkdir -p "$INSTALL_DIR"/bin
mkdir -p "$INSTALL_DIR"/etc
mkdir -p "$INSTALL_DIR"/lib
cp -r "$RUN_BUILDOUT_DIR"/parts/mca/bin/* "$INSTALL_DIR"/bin || true
cp -r "$RUN_BUILDOUT_DIR"/parts/mca/etc/* "$INSTALL_DIR"/etc || true
cp -r "$RUN_BUILDOUT_DIR"/parts/fluentbit-plugin-wendelin/lib/* "$INSTALL_DIR"/lib || true

rm -f clean-stamp
