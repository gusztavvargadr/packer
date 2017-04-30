options = node['gusztavvargadr_packer_w16s']
return if options.nil?

gusztavvargadr_packer_w16s_tools '' do
  tools_options options['tools']
  action :install
end
