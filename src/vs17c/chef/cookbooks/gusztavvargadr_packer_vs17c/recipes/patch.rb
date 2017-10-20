gusztavvargadr_windows_chocolatey_packages '' do
  chocolatey_packages_options node['gusztavvargadr_packer_vs17c']['default']['chocolatey_packages']
end

include_recipe 'gusztavvargadr_packer_w::patch'
