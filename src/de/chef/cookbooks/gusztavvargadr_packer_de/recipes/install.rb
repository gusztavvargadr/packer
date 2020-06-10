include_recipe 'gusztavvargadr_packer_w::install'

gusztavvargadr_docker_engine 'enterprise' do
  action :install
end
