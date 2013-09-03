#! /bin/bash
#
function check_os_is_wow64()
{
  [[ $(uname) == CYGWIN_NT-*-WOW64 ]]
}
readonly -f check_os_is_wow64

function show_usage()
{
    echo "This script is used to build a bootstrap slapos in cywin."
    echo ""
    echo "Usage:"
    echo ""
    echo "  ./slapos-cygwin-bootstrap.sh"
    echo ""
    echo "Before run this script, type the following command in the windows"
    echo "command console to install cygwin:"
    echo ""
    echo "  setup_cygwin.bat C:\slapos-bootstrap network"
    echo ""
    echo "Then sign up slapos.org, got the following certificate files:"
    echo ""
    echo "  certificate"
    echo "  key"
    echo "  computer.key"
    echo "  computer.crt"
    echo ""
    echo "save them in your home path."
    echo ""
}
readonly -f show_usage

export PATH=/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin:$PATH
if ! source /usr/share/csih/cygwin-service-installation-helper.sh ; then
    echo "Error: Missing csih package."
    exit 1
fi

csih_inform "Starting bootstrap slapos node ..."
echo ""

# ======================================================================
# Constants
# ======================================================================
declare -r slapos_prefix=slapboot-
declare -r slapos_client_home=~/.slapos
declare -r client_configure_file=$slapos_client_home/slapos.cfg
declare -r client_certificate_file=$slapos_client_home/certificate
declare -r client_key_file=$slapos_client_home/key

declare -r node_certificate_file=/etc/opt/slapos/ssl/computer.crt
declare -r node_key_file=/etc/opt/slapos/ssl/computer.key
declare -r node_configure_file=/etc/opt/slapos/slapos.cfg

declare -r ipv4_local_network=10.202.29.0/24
declare -r ipv6_local_address=2001:67c:1254:e:32::1

declare -r slapos_administrator=${slapos_prefix:-slap}root
declare -r slapos_user_basename=${slapos_prefix:-slap}user
declare -r slapos_ifname=${slapos_prefix}re6stnet-lo
declare -r re6stnet_service_name=${slapos_prefix}re6stnet
declare -r cron_service_name=${slapos_prefix}cron
declare -r syslog_service_name=${slapos_prefix}syslog-ng
declare -r cygserver_service_name=${slapos_prefix}cygserver

declare -r slapos_installer_software=http://git.erp5.org/gitweb/slapos.git/blob_plain/refs/heads/cygwin-share:/software/slapos-windows-installer/software.cfg
declare -r cygwin_home=$(cygpath -a $(cygpath -w /)\\.. | sed -e "s%/$%%")

# -----------------------------------------------------------
# Local variable
# -----------------------------------------------------------
declare _administrator=${slapos_administrator}
declare _password=
declare _computer_certificate=
declare _computer_key=
declare _client_certificate=
declare _client_key=
declare _ipv4_local_network=${ipv4_local_network}

# -----------------------------------------------------------
# Command line options
# -----------------------------------------------------------
while test $# -gt 0; do
    # Normalize the prefix.
    case "$1" in
    -*=*) optarg=`echo "$1" | sed 's/[-_a-zA-Z0-9]*=//'` ;;
    *) optarg= ;;
    esac

    case "$1" in
    --password=*)
    _password=$optarg
    ;;
    -P)
    _password=$2
    shift
    ;;
    -P)
    _administrator=$2
    shift
    ;;
    --computer-certificate=*)
    _computer_certificate=$optarg
    ;;
    --computer-key=*)
    _computer_key=$optarg
    ;;
    --client-certificate=*)
    _client_certificate=$optarg
    ;;
    --client-key=*)
    _client_key=$optarg
    ;;
    --ipv4-local-network=*)
    [[ x$optarg == x*.*.*.*/* ]] ||
    csih_error "invalid --ipv4-local-network=$optarg, no match x.x.x.x/x"
    _ipv4_local_network=$optarg
    ;;
    *)
    show_usage
    exit 1
    ;;
    esac

    # Next please.
    shift
done

# -----------------------------------------------------------
# Patch cygwin packages for building slapos
# -----------------------------------------------------------
csih_inform "Patching cygwin packages for building slapos"

csih_check_program_or_error /usr/bin/cygport cygport
csih_check_program_or_error /usr/bin/libtool libtool

csih_inform "libtool patched"
sed -i -e "s/4\.3\.4/4.5.3/g" /usr/bin/libtool

csih_inform "/etc/passwd generated"
[[ -f /etc/passwd ]] || mkpasswd > /etc/passwd

csih_inform "/etc/group generated"
[[ -f /etc/group ]] || mkgroup > /etc/group

_filename=$(cygpath -a -w $(cygpath -w /)\\..\\setup.exe)
csih_inform "check ${_filename}"
[[ -f $(cygpath -u ${_filename}) ]] || csih_error "missing ${_filename}"

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
    wget -c http://git.erp5.org/gitweb/slapos.package.git/blob_plain/heads/cygwin:/windows/scripts/${_cmdname} -O /usr/bin/${_cmdname} ||
    csih_error "download ${_cmdname} failed"
    csih_inform "download cygwin script ${_cmdname} OK"
    chmod +x /usr/bin/${_cmdname} || csih_error "chmod /usr/bin/${_cmdname} failed"
done

if check_os_is_wow64 ; then
    wget -c http://dashingsoft.com/products/slapos/ipwin-x64.exe -O /usr/bin/ipwin.exe ||
    csih_error "download ipwin-x64.exe failed"
    csih_inform "download ipwin-x64.exe OK"
else
    wget -c http://dashingsoft.com/products/slapos/ipwin-x86.exe -O /usr/bin/ipwin.exe ||
    csih_error "download ipwin-x86.exe failed"
    csih_inform "download ipwin-x86.exe OK"
fi
chmod +x /usr/bin/ipwin.exe || csih_error "chmod /usr/bin/ipwin.exe failed"

csih_inform "Patch cygwin packages for building slapos OK"
echo ""

# -----------------------------------------------------------
# Install network interface used by slapos node
# -----------------------------------------------------------
csih_inform "Starting configure slapos network ..."
if ! netsh interface ipv6 show interface | grep -q "\\b${slapos_ifname}\\b" ; then
    csih_inform "Installing network interface ${slapos_ifname} ..."
    ipwin install netloop.inf *msloop ${slapos_ifname} ||
    csih_error "install network interface ${slapos_ifname} failed"
fi
ip -4 addr add $(echo ${ipv4_local_network} | sed -e "s%\.0/%.1/%g") dev ${slapos_ifname} ||
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

[[ -f /opt/slapos/buildout.cfg ]] ||
(cd /opt/slapos && echo "[buildout]
extends = http://git.erp5.org/gitweb/slapos.git/blob_plain/refs/heads/cygwin-share:/component/slapos/buildout.cfg
download-cache = /opt/download-cache
prefix = ${buildout:directory}
" > buildout.cfg) &&
csih_inform "buildout.cfg generated"

[[ -f /opt/slapos/bootstrap.py ]] ||
(cd /opt/slapos &&
python -S -c 'import urllib2;print urllib2.urlopen("http://git.erp5.org/gitweb/slapos.core.git/blob_plain/HEAD:/bootstrap.py").read()' > bootstrap.py ) ||
csih_error "download bootstrap.py failed"
csih_inform "download bootstrap.py OK"

[[ -f /opt/slapos/bin/buildout ]] ||
(cd /opt/slapos && python -S bootstrap.py) ||
csih_error "run bootstrap.py failed"
csih_inform  "run bootstrap.py OK"

csih_inform "start bin/buildout"
(cd /opt/slapos ; bin/buildout -v -N) || csih_error "bin/buildout failed"

_filename=~/slapos-core-format.patch
wget -c http://git.erp5.org/gitweb/slapos.package.git/blob_plain/heads/cygwin:/windows/patches/$(basename ${_filename}) -O ${_filename} ||
csih_error "download ${_filename} failed"
csih_inform "download ${_filename} OK"

csih_inform "applay patch ${_filename}"
(cd $(ls -d /opt/slapos/eggs/slapos.core-*.egg/) &&
csih_inform "patch at $(pwd)" &&
patch -f --dry-run -p1 < ${_filename} > /dev/null &&
patch -p1 < ${_filename} &&
csih_inform "apply patch ${_filename} OK")

_filename=~/supervisor-cygwin.patch
wget -c http://git.erp5.org/gitweb/slapos.package.git/blob_plain/heads/cygwin:/windows/patches/$(basename ${_filename}) -O ${_filename} ||
csih_error "download ${_filename} failed"
csih_inform "download ${_filename} OK"

csih_inform "applay patch ${_filename}"
(cd $(ls -d /opt/slapos/eggs/supervisor-*.egg)/supervisor &&
csih_inform "patch at $(pwd)" &&
patch -f --dry-run -p1 < ${_filename} > /dev/null &&
patch -p1 < ${_filename} &&
csih_inform "apply patch ${_filename} OK")

csih_inform "Run buildout of slapos node OK"
echo ""

# -----------------------------------------------------------
# Configure slapos node and client
# -----------------------------------------------------------
csih_inform "Starting configure slapos client and node ..."

for _name in certificate key computer.key computer.crt ; do
    [[ -f ~/${_name} ]] || csih_error "missing file ~/${_name}"
done
for _name in test-computer.key test-computer.crt ; do
    [[ -f ${cygwin_home}/${_name} ]] || csih_error "missing file ${cygwin_home}/${_name}"
done
cp ~/certificate ${cygwin_home} && csih_inform "copy ~/certificate to ${cygwin_home}"
cp ~/key ${cygwin_home} && csih_inform "copy ~/key to ${cygwin_home}"

csih_inform "mkdir /etc/opt/slapos/ssl/partition_pki"
mkdir -p /etc/opt/slapos/ssl/partition_pki
csih_inform "mkdir ${slapos_client_home}"
mkdir -p ${slapos_client_home}

(cp ~/certificate ${client_certificate_file} &&
cp ~/key ${client_key_file} &&
cp ~/computer.crt ${node_certificate_file} &&
cp ~/computer.key ${node_key_file} &&
csih_inform "copy certificate/key files OK") ||
csih_error "copy certificate/key files failed"

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

wget -c http://git.erp5.org/gitweb/slapos.core.git/blob_plain/HEAD:/slapos.cfg.example -O ${node_configure_file} ||
csih_error "download ${node_configure_file} failed"
csih_inform "download ${node_configure_file} OK"
wget -c http://git.erp5.org/gitweb/slapos.core.git/blob_plain/HEAD:/slapos-client.cfg.example -O ${client_configure_file} ||
csih_error "download ${node_configure_file} failed"
csih_inform "download ${node_configure_file} OK"

csih_inform "ipv4_local_network is ${ipv4_local_network}"
sed -i  -e "s%^\\s*interface_name.*$%interface_name = ${interface_guid}%" \
        -e "s%^#\?\\s*ipv6_interface.*$%# ipv6_interface =%g" \
        -e "s%^ipv4_local_network.*$%ipv4_local_network = ${ipv4_local_network}%" \
        -e "s%^computer_id.*$%computer_id = ${computer_guid}%" \
        -e "s%^user_base_name =.*$%user_base_name = ${slapos_user_basename}%" \
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
csih_inform "Formatting SlapOS Node ..."

netsh interface ipv6 add addr ${slapos_ifname} ${ipv6_local_address}
/opt/slapos/bin/slapos node format -cv --now ||
csih_error "Run slapos node format failed. "

echo ""

# -----------------------------------------------------------
# Check and configure cygwin environments
# -----------------------------------------------------------
csih_check_program_or_error /usr/bin/cygrunsrv cygserver
csih_check_program_or_error /usr/bin/syslog-ng-config syslog-ng
csih_check_program_or_error /usr/bin/openssl openssl
csih_check_program_or_error /usr/bin/ipwin slapos-patches
csih_check_program_or_error /usr/bin/slapos-cron-config slapos-patches

if [[ ! ":$PATH" == :/opt/slapos/bin: ]] ; then
    for profile in ~/.bash_profile ~/.profile ; do
        ! grep -q "export PATH=/opt/slapos/bin:" $profile &&
        csih_inform "add /opt/slapos/bin to PATH" &&
        echo "export PATH=/opt/slapos/bin:\${PATH}" >> $profile
    done
fi

_path=/etc/slapos/scripts
csih_inform "create path: ${_path}"
mkdir -p ${_path}
for _name in slapos-configure.sh slapos-include.sh post-install.sh slapos-cleanup.sh ; do
    wget -c http://git.erp5.org/gitweb/slapos.package.git/blob_plain/heads/cygwin:/windows/scripts/${_name} -O ${_path}/${_name} ||
    csih_error "download ${_name} failed"
    csih_inform "download script ${_path}/${_name} OK"
done

# Set prefix for slapos
if [[ -n ${slapos_prefix} ]] ; then
    echo "Set slapos prefix as ${slapos_prefix}"
    sed -i -e "s%slapos_prefix=.*\$%slapos_prefix=${slapos_prefix}%" ${_path|/slapos-include.sh
fi

# -----------------------------------------------------------
# Create account: slaproot
# -----------------------------------------------------------
# Start seclogon service in the Windows XP
if csih_is_xp ; then
    csih_inform "set start property of seclogon to auto"
    sc config seclogon start= auto ||
    csih_warning "failed to set seclogon to auto start."
# In the later, it's RunAs service, and will start by default
fi

# echo Checking slapos account ${_administrator} ...
slapos_check_and_create_privileged_user ${_administrator} ${_password} ||
csih_error "failed to create account ${_administrator}."

# -----------------------------------------------------------
# Configure cygwin services: cygserver syslog-ng
# -----------------------------------------------------------
csih_inform "Starting configure cygwin services ..."
if ! cygrunsrv --query ${cygserver_service_name} > /dev/null 2>&1 ; then
    csih_inform "run cygserver-config ..."
    /usr/bin/cygserver-config --yes || \
        csih_error "failed to run cygserver-config"
    [[ ${cygserver_service_name} == cygserver ]] ||
    cygrunsrv -I ${cygserver_service_name} -d "CYGWIN ${cygserver_service_name}" -p /usr/sbin/cygserver ||
    csih_error "failed to install service ${cygserver_service_name}"
else
    csih_inform "the cygserver service has been installed"
fi
check_cygwin_service ${cygserver_service_name}

if ! cygrunsrv --query ${syslog_service_name} > /dev/null 2>&1 ; then
    csih_inform "run syslog-ng-config ..."
    /usr/bin/syslog-ng-config --yes || \
        csih_error "failed to run syslog-ng-config"
    [[ ${syslog_service_name} == "syslog-ng" ]] ||
    cygrunsrv -I ${syslog_service_name} -d "CYGWIN ${syslog_service_name}" -p /usr/sbin/syslog-ng -a "-F" ||
    csih_error "failed to install service ${syslog_service_name}"

else
    csih_inform "the syslog-ng service has been installed"
fi
check_cygwin_service ${syslog_service_name}

# Use slapos-cron-config to configure slapos cron service.
if ! cygrunsrv --query ${cron_service_name} > /dev/null 2>&1 ; then
    [[ -x ${slapos_cron_config} ]] ||
    csih_error "Couldn't find slapos cron config script: ${slapos_cron_config}"

    if [[ -z "${csih_PRIVILEGED_PASSWORD}" ]] ; then
        slapos_request_password ${_administrator} "Install cron service need the password of ${_administrator}."
    fi

    csih_inform "run slapos-cron-config ..."
    ${slapos_cron_config} ${cron_service_name} ${_administrator} ${csih_PRIVILEGED_PASSWORD} ||
    csih_error "Failed to run ${slapos_cron_config}"
else
    csih_inform "the cron service has been installed"
fi
check_cygwin_service ${cron_service_name}

csih_inform "Configure cygwin services OK"
echo ""

# -----------------------------------------------------------
# cron: Install cron service and create crontab
# -----------------------------------------------------------
csih_inform "Starting configure section cron ..."

_cron_user=${_administrator}
_crontab_file="/var/cron/tabs/${_cron_user}"
if [[ ! -f ${_crontab_file} ]] ; then
    cat <<EOF  > ${_crontab_file}
SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
MAILTO=""

# Run "Installation/Destruction of Software Releases" and "Deploy/Start/Stop Partitions" once per minute
* * * * * /opt/slapos/bin/slapos node software --verbose --logfile=/opt/slapos/log/slapos-node-software.log > /dev/null 2>&1
* * * * * /opt/slapos/bin/slapos node instance --verbose --logfile=/opt/slapos/log/slapos-node-instance.log > /dev/null 2>&1

# Run "Destroy Partitions to be destroyed" once per hour
0 * * * * /opt/slapos/bin/slapos node report --maximal_delay=3600 --verbose --logfile=/opt/slapos/log/slapos-node-report.log > /dev/null 2>&1

# Run "Check/add IPs and so on" once per hour
0 * * * * /opt/slapos/bin/slapos node format >> /opt/slapos/log/slapos-node-format.log 2>&1
EOF
fi

csih_inform "change owner of ${_crontab_file} to ${_cron_user}"
chown ${_cron_user} ${_crontab_file}

csih_inform "change mode of ${_crontab_file} to 644"
chmod 644 ${_crontab_file}
ls -l ${_crontab_file}

csih_inform "begin of crontab of ${_administrator}:"
csih_inform "************************************************************"
cat ${_crontab_file} || csih_error "No crob tab found."
csih_inform "************************************************************"
csih_inform "end of crontab of ${_administrator}"

csih_inform "Configure section cron OK"
echo ""

echo ""
csih_inform "Configure slapos bootstrap node successfully."
echo ""

read -n 1 -t 60 -p "Press any key to exit..."
exit 0
