include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_iis_server '' do
  version 'default'
  action :install
  not_if { reboot_pending? }
end
