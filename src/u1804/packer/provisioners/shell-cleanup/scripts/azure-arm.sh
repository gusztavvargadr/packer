#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
azure-arm)
  /usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync
esac
