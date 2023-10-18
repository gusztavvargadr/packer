include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_iis_tool 'server:latest' do
  action :install
  not_if { reboot_pending? }
end
