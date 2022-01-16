include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_docker_engine '' do
  edition 'enterprise'
  action :install
  not_if { reboot_pending? }
end
