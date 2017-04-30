options = node['gusztavvargadr_packer_vs17c']
return if options.nil?

gusztavvargadr_packer_vs17c_updates '' do
  updates_options options['updates']
  action :install
end
