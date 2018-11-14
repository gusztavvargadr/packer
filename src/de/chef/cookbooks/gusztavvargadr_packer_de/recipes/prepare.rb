include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_docker_engine 'enterprise' do
  action :prepare
end

powershell_script 'Set SSHD start to Delayed-Auto' do
  code <<-EOH
    sc.exe config sshd start= delayed-auto
  EOH
  action :run
end

powershell_script 'Set WinRM start to Delayed-Auto' do
  code <<-EOH
    sc.exe config winrm start= delayed-auto
  EOH
  action :run
end
