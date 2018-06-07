# gusztavvargadr_windows_powershell_script_elevated 'Pull images' do
#   code <<-EOH
#     docker pull library/hello-world:latest
#   EOH
#   action :run
# end

include_recipe 'gusztavvargadr_packer_w::cleanup'
