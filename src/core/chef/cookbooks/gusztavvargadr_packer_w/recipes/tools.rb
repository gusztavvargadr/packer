options = node['gusztavvargadr_packer_w']
return if options.nil?

gusztavvargadr_packer_w_tools '' do
  tools_options options['tools']
  action :install
end
