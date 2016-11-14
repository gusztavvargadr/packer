action :install do
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
end
