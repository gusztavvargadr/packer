property :updates_options, Hash

default_action :install

action :install do
  return if updates_options.nil?

  gusztavvargadr_packer_core_updates '' do
    updates_options new_resource.updates_options
    action :install
  end

  windows_package '.NET Core Tools Preview 2' do
    source 'https://download.microsoft.com/download/F/6/E/F6ECBBCC-B02F-424E-8E03-D47E9FA631B7/DotNetCore.1.0.1-VS2015Tools.Preview2.0.3.exe'
    installer_type :custom
    options '/install /quiet /norestart'
    action :install
  end

  windows_package '.NET Core SDK' do
    source 'https://download.microsoft.com/download/1/1/4/114223DE-0AD6-4B8A-A8FB-164E5862AF6E/dotnet-dev-win-x64.1.0.3.exe'
    installer_type :custom
    options '/install /quiet /norestart'
    action :install
  end
end
