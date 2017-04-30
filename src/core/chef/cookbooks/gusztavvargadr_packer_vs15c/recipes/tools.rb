options = node['gusztavvargadr_packer_vs15c']
return if options.nil?

gusztavvargadr_packer_vs15c_tools '' do
  tools_options options['tools']
  action :install
end
