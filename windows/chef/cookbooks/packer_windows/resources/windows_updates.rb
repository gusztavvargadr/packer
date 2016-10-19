action :enable do
  powershell_script 'Enable Windows Updates' do
    code <<-EOH
      Set-Service wuauserv -StartupType Manual
      Start-Service wuauserv
    EOH
    action :run
  end
end

action :disable do
  powershell_script 'Disable Windows Updates' do
    code <<-EOH
      Stop-Service wuauserv
      Set-Service wuauserv -StartupType Disabled
    EOH
  end
end

action :install do
  powershell_script 'Install Windows Updates' do
    code <<-EOH
      Install-WindowsUpdate -AcceptEula -SuppressReboots
    EOH
    action :run
  end
end
