include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_mssql_tool 'server:2019-developer' do
  action :install
  not_if { reboot_pending? }
end

installationType = powershell_out('Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name InstallationType').stdout.strip
unless installationType.include?('Server Core')
  gusztavvargadr_mssql_tool 'management-studio:2019' do
    action :install
    not_if { reboot_pending? }
  end
end
