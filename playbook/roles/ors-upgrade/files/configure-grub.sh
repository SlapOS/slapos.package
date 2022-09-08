#!/bin/bash
CONF="/etc/default/grub"
BAK="/tmp/default.grub"
cp $CONF $BAK;
if ! grep -q idle=halt /proc/cmdline; then
  sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT.*\)idle=[a-z]* *\(.*\)/\1\2/g' $CONF;
  sed -i 's/^\(GRUB_CMDLINE_LINUX_DEFAULT.*\)"/\1 idle=halt"/g' $CONF;
  if ! update-grub; then
    cp $BAK $CONF;
    update-grub;
  fi
fi
rm -f $BAK;
