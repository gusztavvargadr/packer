include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_docker_engine 'community' do
  action :prepare
end

powershell_script 'Set service \'WinRM\' to \'Autostart (Delayed)\'' do
  code 'sc.exe config winrm start= delayed-auto'
  action :run
end
