action :enable do
  powershell_script 'Enable UAC' do
    code <<-EOH
      Enable-UAC
    EOH
    action :run
  end
end

action :disable do
  powershell_script 'Disable UAC' do
    code <<-EOH
      Disable-UAC
    EOH
    action :run
  end
end
