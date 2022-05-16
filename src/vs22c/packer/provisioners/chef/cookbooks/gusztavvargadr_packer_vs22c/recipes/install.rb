include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_visualstudio_ide '' do
  version '2022'
  edition 'community'
  action :install
  not_if { reboot_pending? }
end
