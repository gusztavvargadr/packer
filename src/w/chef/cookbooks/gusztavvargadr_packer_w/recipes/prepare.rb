gusztavvargadr_windows_pagefile '' do
  action :disable
end

gusztavvargadr_windows_updates '' do
  action [:enable, :start, :configure]
end

powershell_script 'Set service \'WinRM\' to \'Autostart (Delayed)\'' do
  code 'sc.exe config winrm start= delayed-auto'
  action :run
end
