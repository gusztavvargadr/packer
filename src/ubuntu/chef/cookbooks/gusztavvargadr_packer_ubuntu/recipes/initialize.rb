apt_update '' do
  action :update
end

if hyperv?
  apt_package [ 'linux-azure' ] do
    action :install
    notifies :request_reboot, 'reboot[gusztavvargadr_packer_ubuntu]', :immediately
  end
end

if vbox?
  vbox_version = (shell_out('VBoxControl -v').stdout rescue '').strip

  unless vbox_version.include?('6.') || vbox_version.include?('7.')
    apt_package [ 'build-essential', 'cryptsetup', 'libssl-dev', 'libreadline-dev', 'zlib1g-dev', 'linux-source', 'dkms', 'linux-headers-generic' ] do
      action :install
      notifies :run, 'bash[guest-additions]', :immediately
      notifies :request_reboot, 'reboot[gusztavvargadr_packer_ubuntu]', :immediately
    end

    bash 'guest-additions' do
      code <<-EOH
        VER="`cat /home/vagrant/.vbox_version`";
        ISO="VBoxGuestAdditions_$VER.iso";
        wget http://download.virtualbox.org/virtualbox/$VER/$ISO
        mkdir -p /tmp/vbox;
        mount -o loop $ISO /tmp/vbox;
        sh /tmp/vbox/VBoxLinuxAdditions.run \
            || echo "VBoxLinuxAdditions.run exited $? and is suppressed." \
                "For more read https://www.virtualbox.org/ticket/12479";
        umount /tmp/vbox;
        rm -rf /tmp/vbox;
        rm -f *.iso;
EOH
      action :nothing
    end
  end
end

if vmware?
  vmware_version = (shell_out('vmware-toolbox-cmd -v').stdout rescue '').strip

  unless vmware_version.include?('12.')
    apt_package [ 'open-vm-tools', 'open-vm-tools-desktop' ] do
      action :install
      notifies :request_reboot, 'reboot[gusztavvargadr_packer_ubuntu]', :immediately
    end
  end
end

if !ec2?
  bash 'sshd' do
    code <<-EOH
      SSHD_CONFIG="/etc/ssh/sshd_config"

      # ensure that there is a trailing newline before attempting to concatenate
      sed -i -e '$a\' "$SSHD_CONFIG"

      USEDNS="UseDNS no"
      if grep -q -E "^[[:space:]]*UseDNS" "$SSHD_CONFIG"; then
        sed -i "s/^\s*UseDNS.*/${USEDNS}/" "$SSHD_CONFIG"
      else
        echo "$USEDNS" >>"$SSHD_CONFIG"
      fi

      GSSAPI="GSSAPIAuthentication no"
      if grep -q -E "^[[:space:]]*GSSAPIAuthentication" "$SSHD_CONFIG"; then
        sed -i "s/^\s*GSSAPIAuthentication.*/${GSSAPI}/" "$SSHD_CONFIG"
      else
        echo "$GSSAPI" >>"$SSHD_CONFIG"
      fi
  EOH
    action :run
  end

  file '/etc/netplan/01-netcfg.yaml' do
    content <<-EOH
      network:
        version: 2
        ethernets:
          eth0:
            dhcp4: true
  EOH
    action :create
    notifies :run, 'bash[netcfg]', :immediately
  end

  bash 'netcfg' do
    code <<-EOH
      sed -i 's/GRUB_CMDLINE_LINUX="\\(.*\\)"/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0 \\1"/g' /etc/default/grub
      sed -i "/recordfail_broken=/{s/1/0/}" /etc/grub.d/00_header
      update-grub
  EOH
    action :nothing
    notifies :request_reboot, 'reboot[gusztavvargadr_packer_ubuntu]', :immediately
  end
end

reboot 'gusztavvargadr_packer_ubuntu' do
  action :nothing
end

reboot 'gusztavvargadr_packer_ubuntu::initialize' do
  delay_mins 1
  action :reboot_now
  only_if { reboot_pending? }
end
