#!/bin/sh -eux

# set a default HOME_DIR environment variable if not set
HOME_DIR="${HOME_DIR:-/home/vagrant}";

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso)
    apt-get -y update;

    # VER="`cat $HOME_DIR/.vbox_version`";
    VER="7.0.6";
    ISO="VBoxGuestAdditions_$VER.iso";
    wget http://download.virtualbox.org/virtualbox/$VER/$ISO
    mkdir -p /tmp/vbox;
    mount -o loop $HOME_DIR/$ISO /tmp/vbox;
    sh /tmp/vbox/VBoxLinuxAdditions.run \
        || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
            "For more read https://www.virtualbox.org/ticket/12479";
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f $HOME_DIR/*.iso;

    reboot
esac
