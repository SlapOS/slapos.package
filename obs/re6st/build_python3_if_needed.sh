#!/bin/sh

set -e

# This script compiles python3.7 if current python3 is older than this
# It returns the path of the python3 executable to use

python3 -c 'import sys; sys.exit(1) if sys.version_info < (3, 7) else print(sys.executable)' && exit || true

build_dir=.build

# TODO:how to get this from buildout ?
python3_url=https://www.python.org/ftp/python/3.11.10/Python-3.11.10.tar.xz

md5sum=$(echo -n $python3_url | md5sum | cut -d ' ' -f 1)
ark=$PWD/opt/re6st/download-cache/$md5sum
mkdir -p $build_dir
cd $build_dir
tar --strip-components=1 -xaf "$ark"
./configure >/dev/null 2>&1
make -j 4 >/dev/null 2>&1

readlink -f python
