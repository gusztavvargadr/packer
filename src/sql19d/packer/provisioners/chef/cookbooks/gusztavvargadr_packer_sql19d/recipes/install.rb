include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_mssql_server '' do
  version '2019'
  edition 'developer'
  action [:install, :patch]
  not_if { reboot_pending? }
end

unless windows_server_core?
  gusztavvargadr_mssql_management_studio '' do
    version '2018'
    action :install
    not_if { reboot_pending? }
  end
end
