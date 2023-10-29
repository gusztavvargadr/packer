if guest?
  apt_update '' do
    action :update
  end
end

if vbox?
  apt_package [ 'build-essential', 'cryptsetup', 'libssl-dev', 'libreadline-dev', 'zlib1g-dev', 'linux-source', 'dkms', 'linux-headers-generic' ] do
    action :install
    notifies :run, 'bash[guest-additions]', :immediately
    notifies :request_reboot, 'reboot[gusztavvargadr_packer_ubuntu]', :immediately
  end

  bash 'guest-additions' do
    code <<-EOH
      HOME_DIR="${HOME_DIR:-/home/vagrant}";
      VER="`cat $HOME_DIR/.vbox_version`";
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
EOH
    action :nothing
  end
end

if vmware?
  apt_package [ 'open-vm-tools', 'open-vm-tools-desktop' ] do
    action :install
    notifies :request_reboot, 'reboot[gusztavvargadr_packer_ubuntu]', :immediately
  end
end

if guest? && !vbox? && !vmware?
  apt_package [ 'linux-image-virtual', 'linux-tools-virtual', 'linux-cloud-tools-virtual' ] do
    action :install
    notifies :request_reboot, 'reboot[gusztavvargadr_packer_ubuntu]', :immediately
  end
end

reboot 'gusztavvargadr_packer_ubuntu' do
  action :nothing
end

reboot 'gusztavvargadr_packer_ubuntu::initialize' do
  action :reboot_now
  only_if { reboot_pending? }
end
