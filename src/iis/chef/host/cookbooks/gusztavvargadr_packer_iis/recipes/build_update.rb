include_recipe 'gusztavvargadr_packer_w::build_update'

chocolatey_package 'dotnet4.6.1' do
  # options '--ignorepackagecodes'
  action :install
end
