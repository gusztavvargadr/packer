directory_path = "#{Chef::Config[:file_cache_path]}/packer_visual_studio/2015_professional"

directory directory_path do
  recursive true
  action :create
end

configuration_file_name = '2015_professional.xml'
configuration_file_path = "#{directory_path}/#{configuration_file_name}"

cookbook_file configuration_file_path do
  source configuration_file_name
  cookbook 'packer_visual_studio'
  action :create
end

chocolatey_package 'visualstudio2015professional' do
  options "-packageParameters \"--AdminFile #{configuration_file_path.tr('/', '\\')}\""
  timeout 3600
  action :upgrade
end

directory directory_path do
  action :delete
end
