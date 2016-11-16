action :enable do
  powershell_script 'Enable Remote Desktop' do
    code <<-EOH
      Enable-RemoteDesktop
      netsh advfirewall firewall add rule name="Remote Desktop" dir=in localport=3389 protocol=TCP action=allow
    EOH
    action :run
  end
end
