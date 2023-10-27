#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|hyperv-iso|vmware-iso)
    echo "Create netplan config for eth0"
    cat <<EOF >/etc/netplan/01-netcfg.yaml;
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: true
EOF

    # Disable Predictable Network Interface names and use eth0
    # sed -i 's/en[[:alnum:]]*/eth0/g' /etc/network/interfaces;
    sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 \1"/g' /etc/default/grub;
    sed -i "/recordfail_broken=/{s/1/0/}" /etc/grub.d/00_header;
    update-grub;

    reboot
esac
