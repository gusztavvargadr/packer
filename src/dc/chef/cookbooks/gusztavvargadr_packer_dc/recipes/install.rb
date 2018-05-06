powershell_script 'Set service \'WinRM\' to \'Autostart\'' do
  code 'sc.exe config winrm start= auto'
  action :run
end

include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_docker_engine 'community' do
  action :install
end
