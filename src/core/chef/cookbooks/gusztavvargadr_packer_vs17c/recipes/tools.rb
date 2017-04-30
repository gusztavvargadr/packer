options = node['gusztavvargadr_packer_vs17c']
return if options.nil?

gusztavvargadr_packer_vs17c_tools '' do
  tools_options options['tools']
  action :install
end
