packer_windows_windows_updates '' do
  action :enable
end

packer_windows_windows_feature 'NetFx3' do
  action :enable
end

packer_windows_windows_updates '' do
  action :disable
end

packer_windows_windows_feature 'NetFx4-AdvSrvs' do
  action :enable
end

['IIS-WebServer', 'IIS-ASPNET', 'IIS-ASPNET45'].each do |windows_feature|
  packer_windows_windows_feature windows_feature do
    action :enable
  end
end

chocolatey_package 'dotnet4.6.1' do
  options '--ignorepackagecodes'
  action :install
end
