#!/bin/bash
set -e

source configuration_information.sh

cd $INITIAL_DIR
# Clean the ouput of the cache creation
cd $PARTS_DIR
rm -f buildout.cfg
rm -rf bin/ develop-eggs/ download-cache/ eggs/* parts/
# TODO:
# + clean the output of the bootstraping
# + clean the output of the cache creation
# (+ clean the files removed for OBS ?)
