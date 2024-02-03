apt_update '' do
  action :update
end

if vbox?
  vbox_version = (shell_out('VBoxControl -v').stdout rescue '').strip

  unless vbox_version.include?('6.')
    apt_package [ 'build-essential', 'cryptsetup', 'libssl-dev', 'libreadline-dev', 'zlib1g-dev', 'linux-source', 'dkms', 'linux-headers-generic' ] do
      action :upgrade
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
      action :upgrade
      notifies :request_reboot, 'reboot[gusztavvargadr_packer_ubuntu]', :immediately
    end
  end
end

if !vbox? && !vmware?
  apt_package [ 'linux-image-virtual', 'linux-tools-virtual', 'linux-cloud-tools-virtual' ] do
    action :upgrade
    notifies :request_reboot, 'reboot[gusztavvargadr_packer_ubuntu]', :immediately
  end

  apt_package [ 'linux-tools-generic', 'linux-cloud-tools-generic' ] do
    action :upgrade
    notifies :request_reboot, 'reboot[gusztavvargadr_packer_ubuntu]', :immediately
  end
end

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

reboot 'gusztavvargadr_packer_ubuntu' do
  action :nothing
end

reboot 'gusztavvargadr_packer_ubuntu::initialize' do
  delay_mins 1
  action :reboot_now
  only_if { reboot_pending? }
end
