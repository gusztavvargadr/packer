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
  notifies :request_reboot, 'reboot[windows-uac]'
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
  action [:configure]
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

chocolatey_package 'sdelete' do
  action :upgrade
end

if vbox?
  chocolatey_package 'virtualbox-guest-additions-guest.install' do
    action :upgrade
  end
end
