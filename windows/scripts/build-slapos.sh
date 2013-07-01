#! /bin/bash
export PATH=/usr/local/bin:/usr/bin:$PATH

slapos_home=/opt/slapos
slapos_cache=/opt/download-cache

if [[ ! -d $slapos_home ]] ; then
    echo "Make directory of slapos home: $slapos_home"
    mkdir -p $slapos_home
fi
if [[ ! -d $slapos_cache ]] ; then
    echo "Make directory of slapos cache: $slapos_cache"
    mkdir -p $slapos_cache
fi

cd $slapos_home
if [[ ! -f buildout.cfg ]] ; then
    echo "Create $slapos_home/buildout.cfg"
    echo "[buildout]
extends = http://git.erp5.org/gitweb/slapos.git/blob_plain/refs/heads/cygwin-0:/component/slapos/buildout.cfg
download-cache = /opt/download-cache
prefix = ${buildout:directory}
" > buildout.cfg
else
    echo "Edit $slapos_home/buildout.cfg"
	sed -i -e "s%^extends = .*$%extends = http://git.erp5.org/gitweb/slapos.git/blob_plain/refs/heads/cygwin-0:/component/slapos/buildout.cfg%g" buildout.cfg
fi

if [[ ! -f bootstrap.py ]] ; then
    echo "Download $slapos_home/bootstrap.py"
    python -S -c 'import urllib2;print urllib2.urlopen("http://git.erp5.org/gitweb/slapos.core.git/blob_plain/HEAD:/bootstrap.py").read()' > bootstrap.py
    python -S bootstrap.py
    (($?)) && echo "SlapOS bootstrap failed." && exit 1
fi

bin/buildout -v -N
(($?)) && echo "Buildout SlapOS failed." && exit 1

# apply patches
patch_file=/etc/slapos/patches/slapos-core-format.patch
if [[ -f $patch_file ]] ; then
    echo "Apply patch: $patch_file"
    for x in $(find $slapos_home/eggs -name slapos.core-*.egg ; do
        echo Patching $x ...
        cd $x
        patch -f --dry-run -p1 < $patch_file > /dev/null && patch -p1 < $patch_file && echo Patch $x OK.
    done
fi

echo Build SlapOS successfully.
read -n 1 -p "Press any key to exit..."
exit 0
