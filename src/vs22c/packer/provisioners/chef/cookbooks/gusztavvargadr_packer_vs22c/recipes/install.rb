include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_visualstudio_tool 'ide:2022-community' do
  action :install
  not_if { reboot_pending? }
end
