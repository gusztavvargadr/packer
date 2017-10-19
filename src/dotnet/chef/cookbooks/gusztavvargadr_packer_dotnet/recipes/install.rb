include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_windows_native_packages '' do
  native_packages_options node['gusztavvargadr_packer_dotnet']['default']['native_packages']
end
