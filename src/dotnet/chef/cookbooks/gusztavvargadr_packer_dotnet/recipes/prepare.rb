include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_windows_features '' do
  features_options node['gusztavvargadr_packer_dotnet']['default']['features']
end
