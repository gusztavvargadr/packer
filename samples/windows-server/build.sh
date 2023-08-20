#!/usr/bin/env bash

set -euo pipefail

PROVIDER=$1
BUILD=$2

packer init .

pushd ./chef/
chef install
chef export ./.chef/ --force
popd

packer validate -var provider="$PROVIDER" -only="$BUILD.*" .
packer build -var provider="$PROVIDER" -only="$BUILD.*" -force .
