include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_visualstudio_ide '' do
  version '2019'
  edition 'community'
  action :prepare
end
