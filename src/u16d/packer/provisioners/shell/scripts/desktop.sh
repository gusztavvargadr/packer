#!/bin/sh -eux

apt-get install -y xfce4;

apt-get install -y xrdp;
systemctl enable xrdp;
