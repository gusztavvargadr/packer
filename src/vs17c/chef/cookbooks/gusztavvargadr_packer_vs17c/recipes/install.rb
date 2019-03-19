include_recipe 'gusztavvargadr_packer_w::install'
include_recipe 'gusztavvargadr_visualstudio::2017_community'

# gusztavvargadr_windows_chocolatey_packages '' do
#   options node['gusztavvargadr_packer_vs17c']['default']['chocolatey_packages']
# end
