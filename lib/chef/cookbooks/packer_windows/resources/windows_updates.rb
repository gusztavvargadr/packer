action :enable do
  powershell_script 'Enable Windows Updates' do
    code <<-EOH
      Set-Service wuauserv -StartupType Manual
    EOH
    action :run
  end
end

action :start do
  powershell_script 'Start Windows Updates' do
    code <<-EOH
      Start-Service wuauserv
    EOH
    action :run
  end
end

action :configure do
  powershell_script 'Configure Windows Updates' do
    code <<-EOH
      Install-PackageProvider -Name Nuget -Force
      Install-Module PSWindowsUpdate -Force -Confirm:$false

      Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
    EOH
  end
end

action :install do
  packer_windows_powershell_script_elevated 'Install Windows Updates' do
    code <<-EOH
      Get-WUInstall -MicrosoftUpdate -AcceptAll -IgnoreReboot
    EOH
    timeout 86400
    action :run
  end
end

action :stop do
  powershell_script 'Stop Windows Updates' do
    code <<-EOH
      Stop-Service wuauserv
    EOH
  end
end

action :disable do
  powershell_script 'Disable Windows Updates' do
    code <<-EOH
      Set-Service wuauserv -StartupType Disabled
    EOH
  end
end
