windows_defender_exclusion '' do
  paths ['C:\\']
  action :add
end

windows_uac '' do
  enable_uac false
  action :configure
  notifies :request_reboot, 'reboot[gusztavvargadr_packer_windows]', :immediately
end

registry_key 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System' do
  values [{
    name: 'LocalAccountTokenFilterPolicy',
    type: :dword,
    data: 1,
  }]
  recursive true
  action :create
end

gusztavvargadr_windows_update '' do
  action :initialize
end

registry_key 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Schedule\\Maintenance' do
  values [{
    name: 'MaintenanceDisabled',
    type: :dword,
    data: 1,
  }]
  recursive true
  action :create
end

registry_key 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server' do
  values [{
    name: 'fDenyTSConnections',
    type: :dword,
    data: 0,
  }]
  recursive true
  action :create
end

windows_firewall_rule 'Remote Desktop' do
  direction :inbound
  local_port '3389'
  protocol 'TCP'
  firewall_action :allow
  action :create
end

sdelete_archive_source = 'https://download.sysinternals.com/files/SDelete.zip'
sdelete_archive_target = "#{Chef::Config['file_cache_path']}/SDelete.zip"
sdelete_archive_destination = "#{Chef::Config['file_cache_path']}/sdelete"
sdelete_executable_source = "file:///#{Chef::Config['file_cache_path']}/sdelete/sdelete64.exe"
sdelete_executable_target = "#{powershell_out('$env:SystemRoot').stdout.strip}/System32/sdelete.exe"

remote_file sdelete_archive_target do
  source sdelete_archive_source
  action :create
end

archive_file sdelete_archive_target do
  destination sdelete_archive_destination
  action :extract
end

remote_file sdelete_executable_target do
  source sdelete_executable_source
  action :create
end

if vbox?
  vbox_version = (powershell_out('& "C:/Program Files/Oracle/VirtualBox Guest Additions/VBoxGuest/VBoxControl.exe" -v').stdout rescue '').strip

  unless vbox_version.include?('7.')
    vbox_version = powershell_out('cat $env:HOME/.vbox_version').stdout.strip
    vbox_guest_additions_path = "#{Chef::Config['file_cache_path']}/VBoxGuestAdditions.iso"
    vbox_guest_additions_source = "https://download.virtualbox.org/virtualbox/#{vbox_version}/VBoxGuestAdditions_#{vbox_version}.iso"

    remote_file vbox_guest_additions_path do
      source vbox_guest_additions_source
      action :create
    end

    gusztavvargadr_windows_iso '' do
      iso_path vbox_guest_additions_path
      iso_drive_letter 'Z'
      action :mount
    end

    powershell_script 'Install VirtualBox certificates' do
      code <<-EOH
        Start-Process "VBoxCertUtil.exe" "add-trusted-publisher vbox*.cer --root vbox*.cer" -Wait
      EOH
      cwd 'Z:/cert'
      action :run
    end

    powershell_script 'Install VirtualBox Guest Additions' do
      code <<-EOH
        Start-Process "VBoxWindowsAdditions.exe" "/S" -Wait
      EOH
      cwd 'Z:'
      action :run
      notifies :request_reboot, 'reboot[gusztavvargadr_packer_windows]', :immediately
    end
 
    gusztavvargadr_windows_iso '' do
      iso_path vbox_guest_additions_path
      iso_drive_letter 'Z'
      action :dismount
    end
  end
end

if vmware?
  vmware_version = (powershell_out('& "C:/Program Files/VMware/VMware Tools/VMwareToolboxCmd.exe" -v').stdout rescue '').strip

  unless vmware_version.include?('13.')
    vmware_tools_source = 'https://packages-prod.broadcom.com/tools/releases/13.0.10/x64/VMware-tools-13.0.10-25056151-x64.exe'
    vmware_tools_target = "#{Chef::Config['file_cache_path']}/VMware-tools.exe"

    remote_file vmware_tools_target do
      source vmware_tools_source
      action :create
    end

    powershell_script 'Install VMware Tools' do
      code <<-EOH
        Start-Process "#{vmware_tools_target}" "/S /v /qn REBOOT=R ADDLOCAL=ALL" -Wait
      EOH
      action :run
      notifies :request_reboot, 'reboot[gusztavvargadr_packer_windows]', :immediately
    end
  end
end

if kvm?
  qemu_guest_agent_path = "C:/Program Files/Qemu-ga/qemu-ga.exe"
  unless ::File.exist?(qemu_guest_agent_path)
    virtio_iso_source = 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso'
    virtio_iso_target = "#{Chef::Config['file_cache_path']}/virtio-win.iso"
    virtio_iso_drive_letter = 'Z'

    remote_file virtio_iso_target do
      source virtio_iso_source
      action :create
    end

    gusztavvargadr_windows_iso '' do
      iso_path virtio_iso_target
      iso_drive_letter virtio_iso_drive_letter
      action :mount
    end

    powershell_script 'Install VirtIO Guest Tools' do
      code <<-EOH
        Start-Process "virtio-win-guest-tools.exe" "/install /quiet /norestart" -Wait
      EOH
      cwd 'Z:'
      action :run
      notifies :request_reboot, 'reboot[gusztavvargadr_packer_windows]', :immediately
    end

    gusztavvargadr_windows_iso '' do
      iso_path virtio_iso_target
      iso_drive_letter 'Z'
      action :dismount
    end
  end

  chocolatey_package 'rsync' do
    action :install
  end
end

reboot 'gusztavvargadr_packer_windows' do
  action :nothing
end

reboot 'gusztavvargadr_packer_windows::initialize' do
  delay_mins 1
  action :reboot_now
  only_if { reboot_pending? }
end
