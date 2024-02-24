#!/usr/bin/env bash

set -euo pipefail

cd /var/tmp/packer-build/chef

RUN_OPTIONS="--local-mode"
if ! [ -z ${CHEF_ATTRIBUTES} ]; then
  RUN_OPTIONS="${RUN_OPTIONS} --json-attributes attributes.${CHEF_ATTRIBUTES}.json"
fi

sudo CHEF_LICENSE="accept-silent" chef-client ${RUN_OPTIONS}
