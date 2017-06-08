
# Show grub on boot
sed -i 's/GRUB_HIDDEN_TIMEOUT/#GRUB_HIDDEN_TIMEOUT/' /etc/default/grub
# prevent graphic card failure to block boot
sed -i 's#GRUB_CMDLINE_LINUX_DEFAULT=.*#GRUB_CMDLINE_LINUX_DEFAULT=""#' /etc/default/grub
# reduce grub timeout
sed -i 's#GRUB_TIMEOUT=.*#GRUB_TIMEOUT=5#' /etc/default/grub

update-grub
