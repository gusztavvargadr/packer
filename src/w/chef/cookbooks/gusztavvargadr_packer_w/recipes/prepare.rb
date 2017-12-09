gusztavvargadr_windows_pagefile '' do
  action :disable
end

gusztavvargadr_windows_updates '' do
  action [:enable, :start, :configure]
end

gusztavvargadr_windows_uac '' do
  action :disable
end

gusztavvargadr_windows_remote_desktop '' do
  action :enable
end

gusztavvargadr_windows_defender '' do
  action :disable
end

powershell_script 'Disable maintenance' do
  code <<-EOH
    reg add "HKLM\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Schedule\\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f
  EOH
  action :run
end

powershell_script 'Set service \'WinRM\' to \'Autostart (Delayed)\'' do
  code 'sc.exe config winrm start= delayed-auto'
  action :run
end
