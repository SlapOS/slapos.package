#!/bin/bash
CONF="/etc/network/interfaces"
BAK="/tmp/interfaces.$(date +%s)"
IFACE="$(ip route | grep default | sed 's/.*dev \(\w*\)\( .*$\|$\)/\1/g')"
cp $CONF $BAK;
if ! grep -q ip6tables $CONF; then
  sed -i 's#^\(\s*post-up \)iptables\(.*\)$#\1iptables\2\n\1ip6tables\2#g' $CONF;
fi
if ! ifup --no-act $IFACE; then
  cp $BAK $CONF;
fi
rm -rf $BAK;

CONF="/etc/re6stnet/re6stnet.conf"
sed -i '/^interface/d' $CONF
echo "interface $IFACE" >> $CONF
if ! ps -ax -o cmd | grep babeld | grep -q $IFACE; then
  systemctl restart re6stnet;
fi
