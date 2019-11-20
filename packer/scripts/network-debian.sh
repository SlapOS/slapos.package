#!/bin/sh

# provide ifconfig command
apt-get install -y net-tools

# Starting from Debian9 primary interface is not named eth0 anymore
# so change default interface name to eth0 schema.
# Also, enable memory hotplug auto configuration

sed -i 's#GRUB_CMDLINE_LINUX=.*#GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 memhp_default_state=online"#' /etc/default/grub

update-grub

sed -i 's#allow-hotplug ens3.*#allow-hotplug eth0#' /etc/network/interfaces
sed -i 's#iface ens3 inet dhcp.*#iface eth0 inet dhcp#' /etc/network/interfaces
