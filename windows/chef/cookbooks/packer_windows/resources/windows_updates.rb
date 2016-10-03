action :enable do
  Set-Service wuauserv -StartupType Manual
  Start-Service wuauserv
end

action :disable do
  Stop-Service wuauserv
  Set-Service wuauserv -StartupType Disabled
end

action :install do
  powershell_script 'Install Windows Updates' do
    code <<-EOH
      Install-WindowsUpdate -AcceptEula -SuppressReboots
    EOH
    action :run
  end
end
