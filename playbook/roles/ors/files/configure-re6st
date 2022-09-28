#!/bin/bash
if ip -6 a show dev enp0s31f6 | grep -q fe80; then
  IFACE="enp0s31f6"
elif ip -6 a show dev enp2s0 | grep -q fe80; then
  IFACE="enp2s0"
else
  exit;
fi
CONF="/etc/re6stnet/re6stnet.conf"
sed -i '/^interface/d' $CONF
# Don't run re6st with interface option at Lille Office
if ping6 -q -c2 -w3 fe80::20d:b9ff:fe3f:9055%$IFACE; then
  if ps -ax -o cmd | grep babeld | grep -q $IFACE; then
    systemctl restart re6stnet;
  fi
else
  echo "interface $IFACE" >> $CONF
  if ! ps -ax -o cmd | grep babeld | grep -q $IFACE; then
    systemctl restart re6stnet;
  fi
fi
