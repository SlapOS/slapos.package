#!/bin/bash
CONF="/etc/re6stnet/re6stnet.conf"
IFACE="$(ip route | grep default | sed 's/.*dev \(\w*\)\( .*$\|$\)/\1/g')"
sed -i '/^interface/d' $CONF
echo "interface $IFACE" >> $CONF
if ! ps -ax -o cmd | grep babeld | grep -q $IFACE; then
  systemctl restart re6stnet;
fi
