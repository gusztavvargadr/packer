windows_defender_exclusion '' do
  paths ['C:\\']
  action :add
end

reboot 'windows-uac' do
  action :nothing
end

windows_uac '' do
  enable_uac false
  action :configure
  notifies :request_reboot, 'reboot[windows-uac]', :immediately
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

gusztavvargadr_windows_updates '' do
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
  vbox_guest_additions_installed = powershell_out('(Get-WmiObject -Class Win32_Product | Where-Object -Property Name -Like "*VirtualBox*").Count').stdout.strip != '0'
  unless vbox_guest_additions_installed
    reboot 'vbox' do
      action :nothing
    end

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
      notifies :request_reboot, 'reboot[vbox]', :immediately
    end

    gusztavvargadr_windows_iso '' do
      iso_path vbox_guest_additions_path
      iso_drive_letter 'Z'
      action :dismount
    end
  end
end

if vmware?
  reboot 'vmware' do
    action :nothing
  end

  chocolatey_package 'vmware-tools' do
    returns [0, 2, 3010]
    action :install
    notifies :request_reboot, 'reboot[vmware]', :immediately
  end
end

reboot 'initialize' do
  action :reboot_now
  only_if { reboot_pending? }
end
