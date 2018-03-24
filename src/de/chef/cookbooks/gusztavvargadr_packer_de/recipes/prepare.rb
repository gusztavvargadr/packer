include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_docker_engine 'enterprise' do
  action :prepare
end
