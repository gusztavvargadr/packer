include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_mssql_server '' do
  version '2017'
  edition 'developer'
  action [:install, :patch]
  not_if { reboot_pending? }
end

installationType = powershell_out('Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name InstallationType').stdout.strip
unless installationType.include?('Server Core')
  gusztavvargadr_mssql_management_studio '' do
    version '2018'
    action :install
    not_if { reboot_pending? }
  end
end
