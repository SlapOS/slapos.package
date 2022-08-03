#!/bin/bash

set -e

source makefile-scripts/compilation-env.sh

# note: /share files such as manpages are not yet supported in this project
mkdir -p "$INSTALL_DIR"/bin
cp -r "$RUN_BUILDOUT_DIR"/parts/fluent-bit/bin/fluent-bit "$INSTALL_DIR"/bin || true
