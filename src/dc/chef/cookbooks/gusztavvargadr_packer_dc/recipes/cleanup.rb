gusztavvargadr_docker_engine 'community' do
  engine_mode 'windows'
  action :switch
end

include_recipe 'gusztavvargadr_packer_w::cleanup'
