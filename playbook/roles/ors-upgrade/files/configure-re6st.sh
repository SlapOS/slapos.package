#!/bin/bash
IFACE="$(ip route | grep default | sed 's/.*dev \(\w*\)\( .*$\|$\)/\1/g')"
CONF="/etc/re6stnet/re6stnet.conf"
sed -i '/^interface/d' $CONF
echo "interface $IFACE" >> $CONF
# Don't run re6st with interface option at Lille Office
if ping6 -q -c2 -w3 fe80::20d:b9ff:fe3f:9055%$IFACE; then
  systemctl stop re6stnet;
elif ! ps -ax -o cmd | grep babeld | grep -q $IFACE; then
  systemctl restart re6stnet;
fi
