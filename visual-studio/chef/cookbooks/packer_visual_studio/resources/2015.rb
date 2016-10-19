property :edition, String, name_property: true

action :install do
  directory_path = "#{Chef::Config[:file_cache_path]}/packer_visual_studio/2015_#{edition}"

  directory directory_path do
    recursive true
    action :create
  end

  configuration_file_name = 'configuration.xml'
  configuration_file_path = "#{directory_path}/#{configuration_file_name}"
  configuration_file_source = "2015_#{edition}.xml"
  cookbook_file configuration_file_path do
    source configuration_file_source
    cookbook 'packer_visual_studio'
    action :create
  end

  installer_file_name = 'installer.exe'
  installer_file_path = "#{directory_path}/#{installer_file_name}"
  installer_file_source = node['packer_visual_studio']["2015_#{edition}"]['installer_file_url']
  remote_file installer_file_path do
    source installer_file_source
    action :create
  end

  powershell_script "Install Visual Studio 2015 #{edition}" do
    code <<-EOH
      Start-Process "#{installer_file_path.tr('/', '\\')}" "/adminfile #{configuration_file_path.tr('/', '\\')} /quiet /norestart" -Wait
    EOH
    action :run
  end
end

