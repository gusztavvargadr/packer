options = node['gusztavvargadr_packer_w12r2s']
return if options.nil?

gusztavvargadr_packer_w12r2s_tools '' do
  tools_options options['tools']
  action :install
end
