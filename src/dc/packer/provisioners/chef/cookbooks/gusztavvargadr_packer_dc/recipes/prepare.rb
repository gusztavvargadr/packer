include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_docker_engine '' do
  edition 'community'
  action :prepare
end
