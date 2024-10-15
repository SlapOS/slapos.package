#!/bin/sh

set -e

# This script compiles python3 if current python3 is older than python3.7 (minimum version required by buildout)
# It returns the path of the python3 executable to use

python3 -c 'import sys; sys.exit(1) if sys.version_info < (3, 7) else print(sys.executable)' && exit

build_dir=.build
ark=$PWD/opt/re6st/python3.tar.xz
mkdir -p $build_dir
cd $build_dir
tar --strip-components=1 -xaf "$ark"
./configure >/dev/null 2>&1
make -j 4 >/dev/null 2>&1

readlink -f python
