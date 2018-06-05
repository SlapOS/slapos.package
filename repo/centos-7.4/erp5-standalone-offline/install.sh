#!/bin/bash

source install.rc

function check_file()
{
  f=$1
  if [[ ! -z "${f// }" ]] ; then
    if [[ ! -f ${f} ]] ; then
      echo "The $2 file '$f' does not exists."
      echo "Please provide file or leave it empty."
      exit 1
    else
      check_file=`mktemp`
      cat ${f} > ${check_file}
    fi
  else
    check_file=''
  fi
}

echo "It is possible to configure SSL key for the host"
echo
echo "Note: Domain name has to match certificate Common Name"
echo
echo "Important: Domain name HAVE TO point to public IP of this machine"
echo "           in order for the installation to work"
echo
echo "Important: The SSL certificate and SSL Key have to match."
echo
echo "Leave empty values for everything, than the automatically generated"
echo "certificate will be used, for the public IP of this host."
echo
echo -n "Please type domain name: "
read fqdn
echo -n "Please type the path to SSL Certificate file: "
read ssl_crt_file
check_file "$ssl_crt_file" "SSL Certificate"
frontend_ssl_crt_file=$check_file
echo -n "Please type the path to SSL Key file: "
read ssl_key_file
check_file "$ssl_key_file" "SSL Key"
frontend_ssl_key_file=$check_file
echo -n "[OPTIONAL] Please type the path to the CA Certificate used to generate the key and certificate file: "
read ssl_ca_crt_file
check_file "$ssl_ca_crt_file" "SSL CA Certificate"
frontend_ssl_ca_crt_file=$check_file

cat > extra_vars.yml <<EOF
frontend_ssl_crt_file: "$frontend_ssl_crt_file"
frontend_ssl_key_file: "$frontend_ssl_key_file"
frontend_ssl_ca_crt_file: "$frontend_ssl_ca_crt_file"
EOF
if [[ ! -z "${fqdn// }" ]] ; then
  echo "frontend_custom_domain: \"$fqdn\"" >> extra_vars.yml
fi

LOG_FILE=install.log

echo -n "Started at " >> $LOG_FILE 2>&1
date >> $LOG_FILE 2>&1
echo -n "Bootstraping the system..."

yum remove -y firewalld >> $LOG_FILE 2>&1
yum install -y slapos.node*rpm >> $LOG_FILE 2>&1
ip -6 addr add fd46::1/64 dev lo >> $LOG_FILE 2>&1
mkdir -p /opt/slapgrid /srv/slapgrid >> $LOG_FILE 2>&1
slapos configure local >> $LOG_FILE 2>&1
pgrep -f 'slapos proxy' >/dev/null || (
  kill `cat /srv/slapgrid/var/run/supervisord.pid` >> $LOG_FILE 2>&1
  sleep 5 >> $LOG_FILE 2>&1
  slapos node instance --now --verbose >> $LOG_FILE 2>&1
  sleep 15 >> $LOG_FILE 2>&1
)
echo "done."
echo -n "Preparing the machine for SlapOS..."
slapos node format --now --alter_user=True >> $LOG_FILE 2>&1
# remove request cronjobs, they will be recreated during ansible run
# and they request the old software releases
rm -f /etc/cron.d/ansible*request*  >> $LOG_FILE 2>&1
# remove any other software from the proxy
/opt/slapos/parts/sqlite3/bin/sqlite3 /opt/slapos/slapproxy.db 'delete from software11 where url not in ("$FRONTEND_SR_URL","$ERP5_SR_URL");'  >> $LOG_FILE 2>&1
echo "done."
echo -n "Installing ERP5 software..."
yum install -y erp5*rpm >> $LOG_FILE 2>&1
echo "done."

echo -n "Instantiating ERP5 instance..."
for i in `seq 10` ; do
  ansible-playbook --extra-vars @extra_vars.yml /opt/slapos.playbook/$PLAYBOOK >> $LOG_FILE 2>&1
  ANSIBLE_RESULT=$?
  if [ "$ANSIBLE_RESULT" == "0" ] ; then
    break
  fi
  sleep 5m
done
echo "done."
if [ "$ANSIBLE_RESULT" == "0" ] ; then
  echo "The instance is ready. Please connect to:"
  tail -n 20 $LOG_FILE | grep https
  tail -n 20 $LOG_FILE | grep username
  exit 0
else
  echo "There was a problem with installation."
  echo "Please inspect 'install.log' for details."
  echo "While submitting support request, please attach 'install.log' file."
  echo "/opt/slapos/log/slapos-node-software.log:" >> $LOG_FILE 2>&1
  cat /opt/slapos/log/slapos-node-software.log >> $LOG_FILE 2>&1
  echo "/opt/slapos/log/slapos-node-instance.log:" >> $LOG_FILE 2>&1
  cat /opt/slapos/log/slapos-node-instance.log >> $LOG_FILE 2>&1
  exit 1
fi