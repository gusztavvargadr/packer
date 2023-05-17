#!/bin/sh -eux
ubuntu_version="`lsb_release -r | awk '{print $2}'`";
major_version="`echo $ubuntu_version | awk -F. '{print $1}'`";

case "$PACKER_BUILDER_TYPE" in
vmware-iso)
  apt-get -y update;

  apt-get -y install open-vm-tools;

  reboot
esac
