#!/bin/sh
LOG_FILE=install.log

echo -n "Started at " >> $LOG_FILE 2>&1
date >> $LOG_FILE 2>&1
echo -n "Bootstraping the system..."

yum remove -y firewalld >> $LOG_FILE 2>&1
yum install -y slapos.node*rpm >> $LOG_FILE 2>&1
ip -6 addr add 2001::1/64 dev lo >> $LOG_FILE 2>&1
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
echo "done."
echo -n "Installing ERP5 software..."
yum install -y erp5*rpm >> $LOG_FILE 2>&1
echo "done."

echo -n "Instantiating ERP5 instance..."
for i in `seq 10` ; do
  ansible-playbook /opt/slapos.playbook/erp5-standalone.yml >> $LOG_FILE 2>&1
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
  exit 1
fi