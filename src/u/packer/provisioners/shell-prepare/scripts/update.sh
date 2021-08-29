#!/bin/sh -eux
export DEBIAN_FRONTEND=noninteractive

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|hyperv-iso|azure-arm)
  # Disable release-upgrades
  sed -i.bak 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades;

  # Disable systemd apt timers/services
  systemctl stop apt-daily.timer;
  systemctl stop apt-daily-upgrade.timer;
  systemctl disable apt-daily.timer;
  systemctl disable apt-daily-upgrade.timer;
  systemctl mask apt-daily.service;
  systemctl mask apt-daily-upgrade.service;
  systemctl daemon-reload;

  # Disable periodic activities of apt to be safe
  cat <<EOF >/etc/apt/apt.conf.d/10periodic;
  APT::Periodic::Enable "0";
  APT::Periodic::Update-Package-Lists "0";
  APT::Periodic::Download-Upgradeable-Packages "0";
  APT::Periodic::AutocleanInterval "0";
  APT::Periodic::Unattended-Upgrade "0";
EOF

  # Clean and nuke the package from orbit
  rm -rf /var/log/unattended-upgrades;
  apt-get -y purge unattended-upgrades ubuntu-release-upgrader-core;

  echo "update the package list"
  apt-get -y update;

  # Upgrade all installed packages incl. kernel and kernel headers
  apt-get -y dist-upgrade -o Dpkg::Options::="--force-confnew";
esac
