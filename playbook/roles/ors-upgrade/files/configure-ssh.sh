#!/bin/bash
CONF="/etc/ssh/sshd_config"
if ! grep -q "^PermitRootLogin yes$" $CONF; then
  sed -i '/^PermitRootLogin/d' $CONF;
  echo "PermitRootLogin yes" >> $CONF;
  systemctl restart sshd;
fi
if ! grep -q "^PasswordAuthentication yes$" $CONF; then
  sed -i '/^PasswordAuthentication/d' $CONF;
  echo "PasswordAuthentication yes" >> $CONF;
  systemctl restart sshd;
fi
