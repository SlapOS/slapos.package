# Update the box
apt-get -y update
apt-get -y upgrade

# Make sure keyboard language is french
sed -i 's#XKBLAYOUT=.*#XKBLAYOUT="fr"#' /etc/default/keyboard
