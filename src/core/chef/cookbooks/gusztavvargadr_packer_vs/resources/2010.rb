property :edition, String, name_property: true

action :install do
  directory_path = "#{Chef::Config[:file_cache_path]}/gusztavvargadr_packer_vs/2010_#{edition}"

  directory directory_path do
    recursive true
    action :create
  end

  configuration_file_name = 'configuration.ini'
  configuration_file_path = "#{directory_path}/#{configuration_file_name}"
  configuration_file_source = "2010_#{edition}.ini"
  cookbook_file configuration_file_path do
    source configuration_file_source
    cookbook 'gusztavvargadr_packer_vs'
    action :create
  end

  installer_file_name = 'installer.exe'
  installer_file_path = "#{directory_path}/#{installer_file_name}"
  installer_file_source = node['gusztavvargadr_packer_vs']["2010_#{edition}"]['installer_file_url']
  remote_file installer_file_path do
    source installer_file_source
    action :create
  end

  gusztavvargadr_windows_powershell_script_elevated "Install Visual Studio 2010 #{edition}" do
    code <<-EOH
      Start-Process "#{installer_file_path.tr('/', '\\')}" "/UnattendFile #{configuration_file_path.tr('/', '\\')} /q /norestart" -Wait
    EOH
    action :run
  end
end
