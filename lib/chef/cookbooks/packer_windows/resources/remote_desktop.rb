action :enable do
  powershell_script 'Enable Remote Desktop' do
    code <<-EOH
      reg add 'HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server' /v fDenyTSConnections /t REG_DWORD /d 0 /f
      netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow
    EOH
    action :run
  end
end
