action :enable do
  powershell_script 'Enable UAC' do
    code <<-EOH
      Set-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System -Name EnableLUA -Value 1
    EOH
    action :run
  end
end

action :disable do
  powershell_script 'Disable UAC' do
    code <<-EOH
      Set-ItemProperty -Path HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System -Name EnableLUA -Value 0
    EOH
    action :run
  end
end
