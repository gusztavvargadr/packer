options = node['gusztavvargadr_packer_os']
return if options.nil?

gusztavvargadr_packer_os_tools '' do
  tools_options options['tools']
  action :install
end
