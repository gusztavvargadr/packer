#!/bin/bash -eux

case "$PACKER_BUILDER_TYPE" in
virtualbox-ovf|hyperv-vmcx|vmware-vmx|qemu)
    pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub";
    mkdir -p $HOME_DIR/.ssh;
    if command -v wget >/dev/null 2>&1; then
        wget --no-check-certificate "$pubkey_url" -O $HOME_DIR/.ssh/authorized_keys;
    elif command -v curl >/dev/null 2>&1; then
        curl --insecure --location "$pubkey_url" > $HOME_DIR/.ssh/authorized_keys;
    else
        echo "Cannot download vagrant public key";
        exit 1;
    fi
    chown -R vagrant $HOME_DIR/.ssh;
    chmod -R go-rwsx $HOME_DIR/.ssh;

    echo "blank netplan machine-id (DUID) so machines get unique ID generated on boot"
    truncate -s 0 /etc/machine-id

    echo "remove the contents of /tmp"
    rm -rf /tmp/*

    echo "force a new random seed to be generated"
    rm -f /var/lib/systemd/random-seed

    echo "clear the history so our install isn't there"
    rm -f /root/.wget-hsts
    export HISTSIZE=0
esac
