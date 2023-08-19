#!/usr/bin/env bash

set -euo pipefail

packer init .

pushd ./chef/
chef install
chef export ./.chef/ --force
popd

packer validate -var provider="$1" -only="core.*" .
