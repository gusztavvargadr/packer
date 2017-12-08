include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_docker_engine 'community' do
  action :prepare
end

include_recipe 'gusztavvargadr_vs::2017_requirements'
