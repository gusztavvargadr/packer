#!/usr/bin/env bash

set -euo pipefail

CONFIGURATION=$1
PROVIDER=$2
BUILD=$3

packer init .

pushd ./chef/
chef install
chef export ./artifacts/ --force
popd

packer validate -var-file="./options.pkrvars.hcl" -var configuration="${CONFIGURATION}" -var provider="${PROVIDER}" -only="${BUILD}.*" .
packer build -var-file="./options.pkrvars.hcl" -var configuration="${CONFIGURATION}" -var provider="${PROVIDER}" -only="${BUILD}.*" -force .
