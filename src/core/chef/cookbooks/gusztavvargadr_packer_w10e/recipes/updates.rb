options = node['gusztavvargadr_packer_w10e']
return if options.nil?

gusztavvargadr_packer_w10e_updates '' do
  updates_options options['updates']
  action :install
end
