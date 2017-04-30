options = node['gusztavvargadr_packer_vs15c']
return if options.nil?

gusztavvargadr_packer_vs15c_updates '' do
  updates_options options['updates']
  action :install
end
