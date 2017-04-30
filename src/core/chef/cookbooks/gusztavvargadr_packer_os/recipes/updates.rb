options = node['gusztavvargadr_packer_os']
return if options.nil?

gusztavvargadr_packer_os_updates '' do
  updates_options options['updates']
  action :install
end
