include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_docker_engine 'enterprise' do
  action :install
end

windows_service 'winrm' do
  action :configure_startup
  startup_type :automatic
  delayed_start false
end

windows_service 'sshd' do
  action :configure_startup
  startup_type :automatic
  delayed_start false
end
