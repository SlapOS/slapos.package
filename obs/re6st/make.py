# This file doesn't force specific versions of re6stnet or slapos.
# It automatically clones missing repositories but doesn't automatically pull.
# You have to choose by using git manually.

# Run with SLAPOS_EPOCH=<N> environment variable (where <N> is an integer > 1)
# if rebuilding for new SlapOS version but same re6stnet.

# Non-obvious dependencies:
# - Debian: python-debian, python3-docutils, python3-venv, iproute2

# This "makefile" is quite smart at only rebuilding the necessary parts after
# some change. The main exception concerns the download-cache & extends-cache,
# because the 'buildout' step is really long. In doubt, and once everything
# works, you should clean up everything before the final prepare+upload.

# TODO:
# - Arch probably needs clean up of *.py[co] files on uninstallation.
#   This is done already for DEB/RPM.
# - RPM: automatic deps to system libraries.
# - Each built package should have its own dist version (something like
#   -<dist-name><dist-version> suffix), at least to know which one is installed
#   after a dist upgrade.
#   On the other side, Debian should normally suggest to reinstall because
#   package metadata usually differ (e.g. installed size or dependencies), even
#   if there's nothing like checksum comparisons. Maybe other dists do as well.
# - Split tarball in several parts (for Debian, this is doable with
#   "debtransform" tag):
#   - 1 file for each one in download-cache
#   - 1 tarball with everything else
#   For faster release after re6st development, an intermediate split could be:
#   - re6stnet sdist
#   - a tarball of remaining download-cache
#   - 1 tarball with everything else
#
# Note that package don't contain *.py[co] files and they're not generated
# at installation. For this package, it's better like this because it minimizes
# disk usage without slowness (executables are either daemons or run as root).
# If this way of packaging is reused for other software, postinst scripts
# should be implemented.

import os, email, shutil, ssl, time, venv
import urllib.request, urllib.parse, urllib.error
from glob import glob
from io import BytesIO
from subprocess import check_call, check_output, run, DEVNULL, STDOUT
from tempfile import TemporaryDirectory
from make import *
from debian.changelog import Changelog
from debian.deb822 import Deb822

BOOTSTRAP = "http://www.nexedi.org/static/packages/source/slapos.buildout/zc.buildout-3.0.1%2Bslapos009.tar.gz"
PACKAGE = "re6st-node"

BIN = "re6st-conf re6st-registry re6stnet".split()
BUILD_KEEP = ("babeld", "bin/buildout", "buildout.cfg",
              "download-cache", "extends-cache", "python3.tar.xz")
NOPART = "chrpath bison flex gnu-config lunzip m4 patch perl popt site_perl xz-utils".split()
TARGET = "opt/re6st"

ROOT = "build"
BUILD = ROOT + "/" + TARGET
DIST = "dist"
OSC = "osc" # usually a symlink to the destination osc folder

re6stnet = git("re6stnet", "https://lab.nexedi.com/nexedi/re6stnet.git",
               "docs".__eq__)
slapos = git("slapos", "https://lab.nexedi.com/nexedi/slapos.git",
             ctime=False) # ignore ctime due to hardlinks to *-cache

os.environ["TZ"] = "UTC"; time.tzset()

def wheel():
    global MTIME, RE6STNET_VERSION, VERSION
    wheel, = glob(BUILD + '/download-cache/dist/re6stnet-*')
    MTIME = os.stat(wheel).st_mtime
    RE6STNET_VERSION = os.path.basename(wheel).split('-', 2)[1]
    VERSION = "%s+slapos%s.g%s" % (
        RE6STNET_VERSION,
        os.getenv("SLAPOS_EPOCH", "1"),
        check_output(("git", "rev-parse", "--short", "HEAD"),
                     cwd="slapos", text=True).strip())
    tarball.provides = "%s/%s_%s.tar.gz" % (DIST, PACKAGE, VERSION),
    deb.provides = deb.provides[0], "%s/%s_%s.dsc" % (DIST, PACKAGE, VERSION)
    mkdir(DIST)
    return wheel

def bootstrapped(task):
    x = BUILD + '/bin/buildout'
    try:
        if not run((x, '-h'), stdout=DEVNULL, stderr=STDOUT).returncode:
            return x, wheel()
    except Exception:
        pass

@task((re6stnet, slapos, 'buildout.cfg.in'), bootstrapped)
def bootstrap(task):
    rmtree(BUILD)
    with TemporaryDirectory('venv', PACKAGE) as venv_dir:
        venv.create(venv_dir, symlinks=True, with_pip=True)
        check_call(('bin/pip', 'install', '--no-cache-dir',
                    'hatchling', 'slapos.libnetworkcache', BOOTSTRAP,
                    ), cwd=venv_dir)
        check_call((venv_dir + '/bin/hatchling', 'build', '-t', 'wheel',
                    '-d', os.path.abspath(BUILD + '/download-cache/dist'),
                    ), cwd=task.inputs[0])
        task.outputs += BUILD + '/bin/buildout', wheel()
        cfg = open(task.inputs[2]).read() % dict(
            RE6STNET_VERSION=RE6STNET_VERSION,
            ROOT='${buildout:directory}/' + os.path.relpath(ROOT, BUILD),
            SLAPOS=os.path.abspath('slapos'),
            TARGET='/'+TARGET)
        with cwd(BUILD):
            os.mkdir('extends-cache')
            open('buildout.cfg', 'w').write(cfg)
            check_call((venv_dir + '/bin/buildout',
                        'buildout:extra-paths=',
                        'bootstrap'))
            # just fix shebang
            check_call((sys.executable, '-S', 'bin/buildout', 'bootstrap'))

@task(bootstrap, BUILD + "/.installed.cfg")
def buildout(task):
    check_call((sys.executable, '-S', 'bin/buildout',), cwd=BUILD)
    # Touch target in case that buildout had nothing to do.
    os.utime(task.output, None)

def tarfile_addfileobj(tarobj, name, dataobj, statobj):
    tarinfo = tarobj.gettarinfo(arcname=name, fileobj=statobj)
    dataobj.seek(0, 2)
    tarinfo.size = dataobj.tell()
    dataobj.seek(0)
    tarobj.addfile(tarinfo, dataobj)

@task(re6stnet)
def upstream(task):
    check_call(("make", "-C", "re6stnet"))
    task.outputs = glob("re6stnet/docs/*.[1-9]")

@task((upstream, buildout,
       "Makefile.in", "build_python3_if_needed", "cleanup", "install-eggs"))
def tarball(task):
    prefix = "%s-%s/" % (PACKAGE, VERSION)
    build_keep = list(BUILD_KEEP)
    build_keep += check_output((sys.executable,
        os.path.relpath(task.inputs[-1], BUILD), '', 'buildout'),
        text=True, cwd=BUILD).splitlines()
    def xform(path):
        if path == "re6stnet/Makefile":
            path = "upstream.mk"
        for p in "re6stnet/", "build/", "":
            if path.startswith(p):
                return prefix + path[len(p):]
    with make_tar_gz(task.output, MTIME, xform) as t:
        s = BytesIO()
        for k in "BIN", "NOPART", "CLEAN_KEEP", "TARGET":
            v = build_keep if k == "CLEAN_KEEP" else globals()[k]
            s.write(("%s = %s\n" % (
                k, v if type(v) is str else ' '.join(v),
            )).encode())
        with open("Makefile.in", 'rb') as x:
            s.write(x.read())
            tarfile_addfileobj(t, "Makefile", s, x)
        for x in task.inputs[-3:]:
            t.add(x)
        t.add("re6stnet/daemon")
        t.add("re6stnet/Makefile")
        for x in upstream.outputs:
            t.add(x)
        filter_ = lambda info: None if info.name.endswith((
            "/.git", "/__pycache__",
        )) else info
        for x in build_keep:
            t.add(BUILD + "/" + x, filter=filter_)

@task(bootstrap, "debian/changelog")
def dch(task):
    changelog = os.getcwd() + "/" + task.output
    with open("re6stnet/debian/common.mk") as mk:
        check_output(("make", "-f", "-", changelog,
                     "PACKAGE=" + PACKAGE, "VERSION=" + VERSION),
                input=mk.read().replace(task.output, changelog).encode(),
                cwd="re6stnet")

@task((dch, tree("debian")), DIST + "/debian.tar.gz")
def deb(task):
    control = open("re6stnet/debian/control")
    d = Deb822(); s = Deb822(control); b = Deb822(control)
    d["Format"] = open("debian/source/format").read().strip()
    d["Source"] = s["Source"] = b["Package"] = PACKAGE
    d["Version"] = VERSION
    d["Architecture"] = b["Architecture"] = "any"
    d["Build-Depends"] = s["Build-Depends"] = \
        "debhelper (>= 10), iproute2" + ''.join(
        # Before 3.10, pip wants distutils.
        ",\n  python3 (>= 3.10) | python3-distutils (>= 3.7) | %s-dev" % x
        for x in "libbz2 libffi liblzma libssl zlib1g".split())
    del s["X-Python3-Version"]
    b["Depends"] = "${shlibs:Depends}, iproute2"
    b["Conflicts"] = b["Provides"] = b["Replaces"] = "re6stnet"
    patched_control = BytesIO(("%s\n%s" % (s, b)).encode('utf-8'))
    open(task.outputs[1], "w").write(str(d))
    date = email.utils.parsedate_tz(Changelog(open(dch.output)).date)
    mtime = time.mktime(date[:9]) - date[9]
    # Unfortunately, OBS does not support symlinks.
    with make_tar_gz(task.outputs[0], mtime, dereference=True) as t:
        added = glob("debian/*")
        t.add("debian", filter=lambda info:
            # https://github.com/openSUSE/obs-build/pull/646
            None if info.name == "debian/source" else info)
        x = "debian/control"
        tarfile_addfileobj(t, x, patched_control, control)
        added.append(x)
        with cwd("re6stnet"):
            upstream = set(glob("debian/*"))
            upstream.difference_update((x, "debian/rules", "debian/source"))
            # check we are aware of any upstream file we override
            assert upstream.isdisjoint(added), upstream.intersection(added)
            for u in sorted(upstream):
                t.add(u)

def _template(task):
    output = (open(task.inputs[-1]).read()
        .replace("%PACKAGE%", PACKAGE)
        .replace("%TARGET%", TARGET)
        .replace("%VERSION%", VERSION)
    )
    open(task.output, 'w').write(output)

rpm, arch = (task((tarball, name + '.in'), DIST + '/' + name)(_template)
             for name in ("re6stnet.spec", "PKGBUILD"))

@task((tarball, deb, rpm, arch, "re6stnet.install", "re6st-node.rpmlintrc"))
def build(task):
    pass

@task(build)
def osc(task):
    check_call(("osc", "up"), cwd=OSC)
    old = set(glob(OSC + "/re6st-node_*"))
    for path in build.inputs:
        shutil.copy2(path, OSC)
        old.discard(OSC + "/" + os.path.basename(path))
    for path in old:
        os.remove(path)
    check_call(("osc", "addremove"), cwd=OSC)
