options = node['gusztavvargadr_packer_w16s']
return if options.nil?

gusztavvargadr_packer_w16s_updates '' do
  updates_options options['updates']
  action :install
end
