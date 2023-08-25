#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIRECTORY=$(dirname "$0")
WORK_DIRECTORY=$(pwd)

CONFIGURATION=$1
PROVIDER=$2
BUILD=$3

packer init $SCRIPT_DIRECTORY

chef install
chef export ./artifacts/chef/ --force

packer validate -var-file="${WORK_DIRECTORY}/options.pkrvars.hcl" -var configuration="${CONFIGURATION}" -var provider="${PROVIDER}" -var build="${BUILD}" -except "*.null.*" $SCRIPT_DIRECTORY

packer build -var-file="${WORK_DIRECTORY}/options.pkrvars.hcl" -var configuration="${CONFIGURATION}" -var provider="${PROVIDER}" -var build="${BUILD}" -except "*.null.*" -force $SCRIPT_DIRECTORY
