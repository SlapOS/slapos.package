#! /bin/bash
#
# This script is used to build a bootstrip slapos in the cywin.
#
# Usage:
#
#   ./slapos-cygwin-bootstrip.sh
#
# Before run this script, type the following command in the windows
# command console to install cygwin:
#
#   setup_cygwin.bat C:\slapos-bootstrip network
#
# Then sign up slapos.org, got the following certificate files:
#
#   certificate
#   key
#
#   computer.key
#   computer.crt
#
# save them in your home path.
#
export PATH=/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin:$PATH
if ! source /usr/share/csih/cygwin-service-installation-helper.sh ; then
    echo "Error: Missing csih package."
    exit 1
fi

csih_inform "Starting bootstrip slapos node ..."
echo ""

# ======================================================================
# Constants
# ======================================================================
declare -r slapos_client_home=~/.slapos
declare -r client_configure_file=$slapos_client_home/slapos.cfg
declare -r client_certificate_file=$slapos_client_home/certificate
declare -r client_key_file=$slapos_client_home/key

declare -r node_certificate_file=/etc/opt/slapos/ssl/computer.crt
declare -r node_key_file=/etc/opt/slapos/ssl/computer.key
declare -r node_configure_file=/etc/opt/slapos/slapos.cfg

declare -r slapos_ifname=re6stnet-boot
declare -r ipv4_local_network=10.202.29.0/24
declare -r ipv6_local_address=2001:67c:1254:e:32::1

declare -r slapos_installer_software=http://git.erp5.org/gitweb/slapos.git/blob_plain/refs/heads/cygwin-share:/software/slapos-windows-installer/software.cfg

# -----------------------------------------------------------
# Patch cygwin packages for building slapos
# -----------------------------------------------------------
csih_inform "Patching cygwin packages for building slapos"

csih_inform "libtool patched"
sed -i -e "s/4\.3\.4/4.5.3/g" /usr/bin/libtool

csih_inform "/etc/passwd generated"
[[ -f /etc/passwd ]] || mkpasswd > /etc/passwd

csih_inform "/etc/group generated"
[[ -f /etc/group ]] || mkgroup > /etc/group


_filename=/usr/bin/cygport
if [[ -f ${_filename} ]] ; then
    csih_inform "Patching ${_filename} ..."
    sed -i -e 's/D="${workdir}\/inst"/D="${CYGCONF_PREFIX-${workdir}\/inst}"/g' ${_filename} &&
    csih_inform "OK"
else
    csih_error "Missing cygport package, no ${_filename} found."
fi
_filename=/usr/share/cygport/cygclass/autotools.cygclass
if [[ -f ${_filename} ]] ; then
    csih_inform "Patching ${_filename} ..."
    sed -i -e 's/prefix=$(__host_prefix)/prefix=${CYGCONF_PREFIX-$(__host_prefix)}/g' ${_filename} &&
    csih_inform "OK"
else
    csih_error "Missing cygport package, no ${_filename} found."
fi
_filename=/usr/share/cygport/cygclass/cmake.cygclass
if [[ -f ${_filename} ]] ; then
    csih_inform "Patching ${_filename} ..."
    sed -i -e 's/-DCMAKE_INSTALL_PREFIX=$(__host_prefix)/-DCMAKE_INSTALL_PREFIX=${CYGCONF_PREFIX-$(__host_prefix)}/g' ${_filename} &&
    csih_inform "OK"
else
    csih_error "Missing cygport package, no ${_filename} found."
fi

for _cmdname in ip useradd usermod groupadd brctl tunctl ; do
    wget http://git.erp5.org/gitweb/slapos.package.git/blob_plain/heads/cygwin:/windows/scripts/${_cmdname} -O /usr/bin/${_cmdname} ||
    csih_error "download ${_cmdname} failed"
    csih_inform "download cygwin script ${_cmdname} OK"
done

if csih_is_vista ; then
    wget http://dashingsoft.com/products/slapos/ipwin_x64.exe -O /usr/bin/ipwin.exe ||
    csih_error "download ipwin_x64.exe failed"
    csih_inform "download ipwin_x64.exe OK"
else
    wget http://dashingsoft.com/products/slapos/ipwin_x86.exe -O /usr/bin/ipwin.exe ||
    csih_error "download ipwin_x86.exe failed"
    csih_inform "download ipwin_x86.exe OK"
fi

csih_inform "Patch cygwin packages for building slapos OK"
echo ""

# -----------------------------------------------------------
# Install network interface used by slapos node
# -----------------------------------------------------------
csih_inform "Starting configure slapos network ..."
if ! netsh interface ipv6 show interface | grep -q "\\b${slapos_ifname}\\b" ; then
    csih_inform "Installing network interface ${slapos_ifname} ..."
    ipwin install $WINDIR\\inf\\netloop.inf *msloop ${slapos_ifname} ||
    csih_error "install network interface ${slapos_ifname} failed"
fi
ip -4 addr add $(echo ${ipv4_local_network} | sed -e "s%\.0/%.1/%g") dev $slapos_ifname ||
csih_error "add ipv4 address failed"

csih_inform "Configure slapos network OK"
echo ""

# -----------------------------------------------------------
# Check IPv6 protocol, install it if it isn't installed
# -----------------------------------------------------------
csih_inform "Starting configure IPv6 protocol ..."
netsh interface ipv6 show interface > /dev/null || \
    netsh interface ipv6 install || \
    csih_error "install IPv6 protocol failed"
csih_inform "Configure IPv6 protocol OK"
echo ""

# -----------------------------------------------------------
# Run the buildout of slapos node
# -----------------------------------------------------------
csih_inform "Starting run buildout of slapos node ..."

csih_inform "mkdir /opt/slapos/log"
mkdir -p /opt/slapos/log

csih_inform "mkdir /opt/download-cache"
mkdir -p /opt/download-cache

(cd /opt/slapos && echo "[buildout]
extends = http://git.erp5.org/gitweb/slapos.git/blob_plain/refs/heads/cygwin-share:/component/slapos/buildout.cfg
download-cache = /opt/download-cache
prefix = ${buildout:directory}
" > buildout.cfg &&
csih_inform "buildout.cfg generated")

python -S -c 'import urllib2;print urllib2.urlopen("http://git.erp5.org/gitweb/slapos.core.git/blob_plain/HEAD:/bootstrap.py").read()' > bootstrap.py ||
csih_error "download bootstrap.py failed"
csih_inform "download bootstrap.py OK"

python -S bootstrap.py || csih_error "run bootstrap.py failed"
csih_inform  "run bootstrap.py OK"

csih_inform "start bin/buildout"
bin/buildout -v -N || csih_error "bin/buildout failed"

_filename=~/slapos-core-format.patch
wget http://git.erp5.org/gitweb/slapos.package.git/blob_plain/heads/cygwin:/windows/patches/slapos-core-format.patch -O ${_filename} ||
csih_error "download ${_filename} failed"
csih_inform "download ${_filename} OK"

((cd $(ls -d /opt/slapos/eggs/slapos.core-*.egg/) || csih_error "no slapos.core egg found") &&
csih_inform "patch at $(pwd)" &&
patch -f --dry-run -p1 < ${_filename} > /dev/null &&
patch -p1 < ${_filename} &&
csih_inform "apply patch ${_filename}")

csih_inform "Run buildout of slapos node OK"
echo ""

# -----------------------------------------------------------
# Configure slapos node and client
# -----------------------------------------------------------
csih_inform "Starting configure slapos client and node ..."

for _name in certificate key computer.key computer.crt ; do
    [[ -f ~/${_name} ]] || csih_error "missing file ~/${_name}"
done

csih_inform "mkdir /etc/opt/slapos/ssl/partition_pki"
mkdir -p /etc/opt/slapos/ssl/partition_pki
csih_inform "mkdir ${slapos_client_home}"
mkdir -p ${slapos_client_home}

computer_guid=$(grep "CN=COMP" ${node_certificate_file} | \
    sed -e "s/^.*, CN=//g" | sed -e "s%/emailAddress.*\$%%g")
[[ "${computer_guid}" == COMP-+([0-9]) ]] ||
csih_error_multi "${computer_guid} is invalid computer guid." \
    "It should like 'COMP-XXXX', edit ${node_certificate_file}" \
    "to fix it."
csih_inform "computer reference id: ${computer_guid}"

interface_guid=$(ipwin guid *msloop ${slapos_ifname}) ||
csih_error "get guid of interface ${slapos_ifname} failed"
[[ "$interface_guid" == {*-*-*-*} ]] ||
csih_error "invalid interface guid ${interface_guid} specified."
csih_inform "the guid of interface ${slapos_ifname} is ${interface_guid}"

wget http://git.erp5.org/gitweb/slapos.core.git/blob_plain/HEAD:/slapos.cfg.example -O ${node_configure_file} ||
csih_error "download ${node_configure_file} failed"
csih_inform "download ${node_configure_file} OK"
wget http://git.erp5.org/gitweb/slapos.core.git/blob_plain/HEAD:/slapos-client.cfg.example -O ${client_configure_file} ||
csih_error "download ${node_configure_file} failed"
csih_inform "download ${node_configure_file} OK"

csih_inform "ipv4_local_network is ${ipv4_local_network}"
sed -i  -e "s%^\\s*interface_name.*$%interface_name = ${interface_guid}%" \
        -e "s%^#\?\\s*ipv6_interface.*$%# ipv6_interface =%g" \
        -e "s%^ipv4_local_network.*$%ipv4_local_network = ${ipv4_local_network}%" \
        -e "s%^computer_id.*$%computer_id = ${computer_guid}%" \
        ${node_configure_file}
csih_inform "type ${node_configure_file}:"
csih_inform "************************************************************"
cat ${node_configure_file}
csih_inform "************************************************************"

sed -i -e "s%^cert_file.*$%cert_file = ${client_certificate_file}%" \
       -e "s%^key_file.*$%key_file = ${client_key_file}%" \
       ${client_configure_file}
csih_inform "type ${client_configure_file}:"
csih_inform "************************************************************"
cat ${client_configure_file}
csih_inform "************************************************************"

csih_inform "Configure slapos client and node OK"
echo ""
# -----------------------------------------------------------
# Format slapos node
# -----------------------------------------------------------
csih_inform "Formating SlapOS Node ..."

/opt/slapos/bin/slapos node format -cv --now ||
csih_error "Run slapos node format failed. "

echo ""

# -----------------------------------------------------------
# Request an instance of slapos webrunner
# -----------------------------------------------------------
csih_inform "Supply slapos_installer_software in the ${computer_guid}"

csih_inform "  ${slapos_installer_software}"
/opt/slapos/bin/slapos supply ${slapos_installer_software} ${computer_guid}
_title="SlapOS-Windows-Installer-In-${computer_guid}"

csih_inform "Request an instance as ${_title}"
/opt/slapos/bin/slapos request ${client_configure_file} ${_title} \
    ${slapos_installer_software} --node computer_guid=${computer_guid}

echo ""

# -----------------------------------------------------------
# Enter loop to release software, create an instance, report
# -----------------------------------------------------------
while true ; do
    csih_inform "Releasing software ..."
    /opt/slapos/bin/slapos node software --verbose || continue

    csih_inform "Creating instance ..."
    /opt/slapos/bin/slapos node instance --verbose

    csih_inform "Sending report ..."
    /opt/slapos/bin/slapos node report --verbose

    /opt/slapos/bin/slapos request ${client_configure_file} ${_title} \
        ${slapos_installer_software} --node computer_guid=${computer_guid} &&
    break
done

echo ""
csih_inform "Bootstrip slapos node successfully."
echo ""

read -n 1 -t 60 -p "Press any key to exit..."
exit 0
