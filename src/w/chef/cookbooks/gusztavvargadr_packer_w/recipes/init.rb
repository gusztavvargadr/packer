gusztavvargadr_windows_powershell_script_elevated 'Configure OS services' do
  code <<-EOH
    Write-Host "Disable Windows Defender"
    Set-MpPreference -DisableRealtimeMonitoring $True -ExclusionPath "C:\"
    
    Write-Host "Disable Windows Updates"
    reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU" /v NoAutoUpdate /d 1 /t REG_DWORD /f /reg:64
    
    Write-Host "Disable Windows Store Updates"
    reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Policies\\Microsoft\\WindowsStore" /v AutoDownload /d 2 /t REG_DWORD /f /reg:64
    
    Write-Host "Disable Maintenance"
    reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Schedule\\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f

    Write-Host "Disable UAC"
    reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System" /v EnableLUA /t REG_DWORD /d 0 /f
    reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System" /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f
    
    Write-Host "Enable Remote Desktop"
    reg add "HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
    netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow
  EOH
  action :run
end

gusztavvargadr_windows_updates '' do
  action [:configure]
end

gusztavvargadr_windows_chocolatey_package 'sdelete' do
  action :install
end

if ENV['PACKER_BUILDER'].to_s.include?('virtualbox')
  gusztavvargadr_packer_w_virtualbox_guest_additions '' do
    guest_additions_options node['gusztavvargadr_packer_w']['virtualbox_guest_additions']
    action :install
  end

  gusztavvargadr_windows_chocolatey_package 'virtio-drivers' do
    action :install
  end
end
