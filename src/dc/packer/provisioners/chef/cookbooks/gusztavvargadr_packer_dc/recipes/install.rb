include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_docker_tool 'engine:latest-community' do
  action [:install, :configure]
  not_if { reboot_pending? }
end
