# features = [
#   'NET-Framework-Features',
#   'NET-Framework-45-Features',
#   'Web-Server'
# ]
# features.each do |feature|
#   packer_windows_feature feature do
#     include_subfeatures true
#     action :install
#   end
# end

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

installer_file_name = 'vs_professional_ENU.exe'
installer_file_path = "#{directory_path}/#{installer_file_name}"

remote_file installer_file_path do
  source "http://download.microsoft.com/download/D/2/8/D28D3B41-BF4A-409A-AFB5-2C82C216D4E1/#{installer_file_name}"
  action :create
end

powershell_script 'Install Visual Studio 2015 Professional' do
  code <<-EOH
    Start-Process "#{installer_file_path.tr('/', '\\')}" "/adminfile #{configuration_file_path.tr('/', '\\')} /quiet /norestart" -Wait
  EOH
  action :run
end

directory directory_path do
  action :delete
end
