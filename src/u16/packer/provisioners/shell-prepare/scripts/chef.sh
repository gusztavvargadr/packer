#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|hyperv-iso|azure-arm)
    apt-get -y install p7zip-full;

    curl -L https://omnitruck.chef.io/install.sh | bash -s -- -v 14.3.37
esac
