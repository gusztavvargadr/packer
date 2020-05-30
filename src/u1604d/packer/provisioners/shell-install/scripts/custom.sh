#!/bin/sh -eux

apt-get install -y xubuntu-desktop;

apt-get install -y xrdp;
systemctl enable xrdp;
