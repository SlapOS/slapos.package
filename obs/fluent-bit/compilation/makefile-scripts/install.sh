#!/bin/bash

set -e

source makefile-scripts/compilation-env.sh

# note: /share files such as manpages are not yet supported in this project
mkdir -p "$INSTALL_DIR"/bin
# no "-r" option to "cp" because there must not be subdirectories in /bin
# https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s04.html
# https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s13.html
cp "$RUN_BUILDOUT_DIR"/parts/fluent-bit/bin/fluent-bit "$INSTALL_DIR"/bin || true

rm -f clean-stamp
