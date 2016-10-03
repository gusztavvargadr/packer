property :edition, String, name_property: true

action :install do
  directory_path = "#{Chef::Config[:file_cache_path]}/packer_visual_studio/2015_#{edition}"

  directory directory_path do
    recursive true
    action :create
  end

  configuration_file_name = "2015_#{edition}.xml"
  configuration_file_path = "#{directory_path}/#{configuration_file_name}"

  cookbook_file configuration_file_path do
    source configuration_file_name
    cookbook 'packer_visual_studio'
    action :create
  end

  chocolatey_package "visualstudio2015#{edition}" do
    options "--ignore-package-exit-codes -params \"--AdminFile #{configuration_file_path.tr('/', '\\')}\""
    timeout 2700
    action :install
  end
end
