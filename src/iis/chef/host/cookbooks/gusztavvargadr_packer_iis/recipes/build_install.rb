include_recipe 'gusztavvargadr_packer_w::build_install'

packer_windows_windows_updates '' do
  action [:enable, :start]
end

['NetFx3', 'NetFx4-AdvSrvs'].each do |windows_feature|
  packer_windows_windows_feature windows_feature do
    action :enable
  end
end

['IIS-WebServer', 'IIS-ASPNET', 'IIS-ASPNET45'].each do |windows_feature|
  packer_windows_windows_feature windows_feature do
    action :enable
  end
end

packer_windows_windows_updates '' do
  action :disable
end
