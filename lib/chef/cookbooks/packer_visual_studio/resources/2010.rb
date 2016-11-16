property :edition, String, name_property: true

action :install do
  directory_path = "#{Chef::Config[:file_cache_path]}/packer_visual_studio/2010_#{edition}"

  directory directory_path do
    recursive true
    action :create
  end

  configuration_file_name = 'configuration.ini'
  configuration_file_path = "#{directory_path}/#{configuration_file_name}"
  configuration_file_source = "2010_#{edition}.ini"
  cookbook_file configuration_file_path do
    source configuration_file_source
    cookbook 'packer_visual_studio'
    action :create
  end

  installer_file_source = node['packer_visual_studio']["2010_#{edition}"]['installer_file_url']
  windows_package "Visual Studio 2010 #{edition}" do
    source installer_file_source
    installer_type :custom
    options "/UnattendFile #{configuration_file_path.tr('/', '\\')} /q /norestart"
    timeout 3600
    action :install
  end

  directory directory_path do
    action :delete
  end
end
