options = node['gusztavvargadr_packer_w10e']
return if options.nil?

gusztavvargadr_packer_w10e_tools '' do
  tools_options options['tools']
  action :install
end
