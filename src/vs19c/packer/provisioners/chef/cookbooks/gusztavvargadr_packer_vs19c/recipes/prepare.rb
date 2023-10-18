include_recipe 'gusztavvargadr_packer_w::prepare'

gusztavvargadr_visualstudio_tool 'ide:2019-community' do
  action :initialize
end
