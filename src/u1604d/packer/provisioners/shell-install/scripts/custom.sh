#!/bin/sh -eux

export DEBIAN_FRONTEND=noninteractive

apt-get install -y xubuntu-desktop;

apt-get install -y xrdp;
systemctl enable xrdp;
usermod -aG ssl-cert xrdp
