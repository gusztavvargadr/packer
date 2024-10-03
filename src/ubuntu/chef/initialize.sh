#!/usr/bin/env bash

set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y curl

mkdir -p /var/tmp/packer-build/chef

if ! [ -x "$(command -v chef-client)" ]; then
  curl -Ls https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chef -v 18.5.0
fi
chef-client --version

sudo lvextend -l +100%FREE -r /dev/mapper/ubuntu--vg-ubuntu--lv

sudo shutdown --reboot +1
