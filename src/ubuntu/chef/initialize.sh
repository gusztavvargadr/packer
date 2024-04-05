#!/usr/bin/env bash

set -euo pipefail

mkdir -p /var/tmp/packer-build/chef

if ! [ -x "$(command -v chef-client)" ]; then
  curl -Ls https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chef -v 18.4.12
  sudo apt-mark hold chef
fi
chef-client --version

sudo lvextend -l +100%FREE -r /dev/mapper/ubuntu--vg-ubuntu--lv

sudo shutdown --reboot +1
