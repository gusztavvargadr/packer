options = node['gusztavvargadr_packer_core']
return if options.nil?

gusztavvargadr_packer_core_tools '' do
  tools_options options['tools']
  action :install
end
