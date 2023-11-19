#!/usr/bin/env bash

set -euo pipefail

sudo mkdir -p /opt/packer-build/chef
sudo chown -R ${SUDO_USER:-${USER}} /opt/packer-build/chef

if ! [ -x "$(command -v chef-client)" ]; then
  curl -Ls https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chef -v 18.3.0
  sudo apt-mark hold chef
fi
chef-client --version
