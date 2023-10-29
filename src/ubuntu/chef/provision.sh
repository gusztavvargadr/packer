#!/usr/bin/env bash

set -euo pipefail

cd /opt/packer-build/chef

sudo CHEF_LICENSE="accept-silent" chef-client --local-mode
