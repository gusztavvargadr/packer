#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|hyperv-iso|azure-arm)
    apt-get -y install p7zip-full;

    curl -L https://omnitruck.chef.io/install.sh | bash -s -- -v 15.10.12
    echo "CHEF_LICENSE=accept-silent" >> /etc/environment
esac

reboot
