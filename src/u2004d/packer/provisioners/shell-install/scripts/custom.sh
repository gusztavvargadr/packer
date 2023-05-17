#!/bin/sh -eux

DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt-get install -y xubuntu-desktop
echo /usr/sbin/lightdm > /etc/X11/default-display-manager
DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true dpkg-reconfigure lightdm

apt-get install -y xrdp
systemctl enable xrdp
usermod -aG ssl-cert xrdp

case "$PACKER_BUILDER_TYPE" in
vmware-iso)
  apt-get -y install open-vm-tools-desktop;

  reboot
esac
