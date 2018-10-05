include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_docker_engine 'community' do
  action :prepare
end

powershell_script 'Set SSHD start to Delayed-Auto' do
  code <<-EOH
    sc.exe config sshd start= delayed-auto
  EOH
  action :run
end
