#!/bin/bash

set -e

source makefile-scripts/compilation-env.sh

mkdir -p "$INSTALL_DIR/bin"
mkdir -p "$INSTALL_DIR/etc"
mkdir -p "$INSTALL_DIR/include"
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/sbin"
mkdir -p "$INSTALL_DIR/share"
# no "-r" option to "cp" because there must not be subdirectories in /bin
# https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch04s04.html
# https://refspecs.linuxfoundation.org/FHS_3.0/fhs/ch03s13.html
cp "$RUN_BUILDOUT_DIR/parts/"*/bin/* "$INSTALL_DIR/bin" || true
cp -r "$RUN_BUILDOUT_DIR/parts/"*/etc/* "$INSTALL_DIR/etc" || true
cp -r "$RUN_BUILDOUT_DIR/parts/"*/include/* "$INSTALL_DIR/include" || true
cp -r "$RUN_BUILDOUT_DIR/parts/"*/lib/* "$INSTALL_DIR/lib" || true
cp -r "$RUN_BUILDOUT_DIR/parts/"*/sbin/* "$INSTALL_DIR/sbin" || true
cp -r "$RUN_BUILDOUT_DIR/parts/"*/share/* "$INSTALL_DIR/share" || true

rm -f clean-stamp
