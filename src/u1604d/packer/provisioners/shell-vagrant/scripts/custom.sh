#!/bin/bash -eux

echo "xfce4-session" > /home/vagrant/.xsession
chown vagrant:vagrant /home/vagrant/.xsession
