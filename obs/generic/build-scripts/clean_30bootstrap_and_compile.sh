#!/bin/bash
set -e

source build-scripts/00env.sh

cd "$INITIAL_DIR"
# Remove the products of the script bootstrap_buildout.sh
# remove the bootstrap script and associated files
rm -f "$RUN_BUILDOUT_DIR"/{bootstrap.py,bootstrap-buildout.py,buildout.cfg}
# remove the material created by the bootstrap script
rm -rf "$RUN_BUILDOUT_DIR"/{bin/,egg/}
# remove the material created by buildout itself
rm -rf "$RUN_BUILDOUT_DIR"/go/
