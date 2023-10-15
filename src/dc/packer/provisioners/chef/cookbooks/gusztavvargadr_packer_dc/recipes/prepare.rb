include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_docker_tool 'engine:latest-community' do
  action :initialize
  not_if { reboot_pending? }
end
