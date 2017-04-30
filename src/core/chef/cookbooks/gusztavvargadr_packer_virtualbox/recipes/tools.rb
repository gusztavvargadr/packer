options = node['gusztavvargadr_packer_virtualbox']
return if options.nil?

gusztavvargadr_packer_virtualbox_tools '' do
  tools_options options['tools']
  action :install
end
