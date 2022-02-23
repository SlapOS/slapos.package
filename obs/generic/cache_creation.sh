#!/bin/bash
set -e

source configuration_information.sh

cd $INITIAL_DIR
# Run bulidout locally to fill download-cache and extends-cache
cd $PARTS_DIR
cp $TEMPLATE_DIR/tmp/buildout_with_gcc.cfg buildout.cfg
# bootstrap again, run buildout if succeeds
# TODO: test if it works in two different lines
(./tmp-networkcached/bin/buildout bootstrap --buildout-version 2.7.1+slapos016 --setuptools-to-dir eggs -f http://www.nexedi.org/static/packages/source/slapos.buildout/ && ./bin/buildout && ./bin/buildout -v)
