options = node['gusztavvargadr_packer_core']
return if options.nil?

gusztavvargadr_packer_core_updates '' do
  updates_options options['updates']
  action :install
end
