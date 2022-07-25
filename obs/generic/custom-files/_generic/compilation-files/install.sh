#!/bin/bash

set -e

source compilation-env.sh

mkdir -p "$INSTALL_DIR"/bin
mkdir -p "$INSTALL_DIR"/sbin/
mkdir -p "$INSTALL_DIR"/etc/
mkdir -p "$INSTALL_DIR"/lib/
mkdir -p "$INSTALL_DIR"/share/
cp -r "$RUN_BUILDOUT_DIR"/parts/*/bin/* "$INSTALL_DIR"/bin/ || true
cp -r "$RUN_BUILDOUT_DIR"/parts/*/sbin/* "$INSTALL_DIR"/sbin/ || true
cp -r "$RUN_BUILDOUT_DIR"/parts/*/etc/* "$INSTALL_DIR"/etc/ || true
cp -r "$RUN_BUILDOUT_DIR"/parts/*/lib/* "$INSTALL_DIR"/lib/ || true
cp -r "$RUN_BUILDOUT_DIR"/parts/*/share/* "$INSTALL_DIR"/share/ || true
