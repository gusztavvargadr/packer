options = node['gusztavvargadr_packer_iis']
return if options.nil?

gusztavvargadr_packer_iis_updates '' do
  updates_options options['updates']
  action :install
end
