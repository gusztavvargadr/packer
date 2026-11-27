#!/usr/bin/env bash

set -euo pipefail

sudo cloud-init status --wait

sudo apt-get update -y
sudo apt-get install -y curl

mkdir -p /var/tmp/packer-build/chef

sudo lvextend -l +100%FREE -r /dev/mapper/ubuntu--vg-ubuntu--lv
