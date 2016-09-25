action :install do
  powershell_script 'Install Windows Updates' do
    code <<-EOH
      Install-WindowsUpdate -AcceptEula -SuppressReboots
    EOH
    action :run
  end
end
