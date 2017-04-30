options = node['gusztavvargadr_packer_iis']
return if options.nil?

gusztavvargadr_packer_iis_tools '' do
  tools_options options['tools']
  action :install
end
