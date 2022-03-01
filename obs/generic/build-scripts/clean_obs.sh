#!/bin/bash
set -e

source build-scripts/configuration_information.sh

TMP_DIR=$INITIAL_DIR/tmp/
TMP_DIR=`realpath -m $TMP_DIR`
rm -rf $TMP_DIR
