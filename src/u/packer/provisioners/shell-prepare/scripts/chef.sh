#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|hyperv-iso|azure-arm)
    curl -L https://omnitruck.chef.io/install.sh | bash -s -- -P chef -v 18.0.185
    echo "CHEF_LICENSE=accept-silent" >> /etc/environment
esac
