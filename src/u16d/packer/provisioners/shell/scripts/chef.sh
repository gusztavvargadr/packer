#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|hyperv-iso)
    curl -L https://omnitruck.chef.io/install.sh | bash -s -- -v 14.3.37
esac
