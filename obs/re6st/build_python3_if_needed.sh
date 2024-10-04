#!/bin/sh

# This script compiles python3.7 if current python3 is older than this
# It returns the path of the python3 executable to use

version=$(python3 --version | sed 's/Python 3.//' | sed 's/\..*//')
if [ $version -ge 7 ]
then
	echo $(which python3)
	exit 0
fi

build_dir=.build

# TODO:how to get this from buildout ?
python3_url=https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tar.xz


md5sum=$(echo -n $python3_url | md5sum | cut -d ' ' -f 1)
mkdir -p $build_dir
cp opt/re6st/download-cache/$md5sum $build_dir/$(basename $python3_url)
cd $build_dir
tar -xJf $(basename $python3_url)
rm $(basename $python3_url)
cd Python*
sh configure &> /dev/null
make -j 4 &> /dev/null

echo $(readlink -f python)
