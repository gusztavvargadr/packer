#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIRECTORY=$(dirname "$0")
WORK_DIRECTORY=$(pwd)

IMAGE=$1
PROVIDER=$2
BUILD=$3

packer init $SCRIPT_DIRECTORY
# packer init -upgrade $SCRIPT_DIRECTORY

# packer console -var-file="${WORK_DIRECTORY}/images.pkrvars.hcl" -var image="${IMAGE}" -var provider="${PROVIDER}" -var build="${BUILD}" $SCRIPT_DIRECTORY
# exit

packer validate -var-file="${WORK_DIRECTORY}/images.pkrvars.hcl" -var image="${IMAGE}" -var provider="${PROVIDER}" -var build="${BUILD}" -only "chef.*" $SCRIPT_DIRECTORY
packer build -var-file="${WORK_DIRECTORY}/images.pkrvars.hcl" -var image="${IMAGE}" -var provider="${PROVIDER}" -var build="${BUILD}" -only "chef.*" -force $SCRIPT_DIRECTORY

packer validate -var-file="${WORK_DIRECTORY}/images.pkrvars.hcl" -var image="${IMAGE}" -var provider="${PROVIDER}" -var build="${BUILD}" -only "${BUILD}.*" $SCRIPT_DIRECTORY
packer build -var-file="${WORK_DIRECTORY}/images.pkrvars.hcl" -var image="${IMAGE}" -var provider="${PROVIDER}" -var build="${BUILD}" -only "${BUILD}.*" -force $SCRIPT_DIRECTORY
