include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_docker_engine '' do
  edition 'enterprise'
  action :prepare
end
