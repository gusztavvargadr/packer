include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_docker_engine 'enterprise' do
  action :install
end

powershell_script 'Set SSHD start to Auto' do
  code <<-EOH
    sc.exe config sshd start= auto
  EOH
  action :run
end
