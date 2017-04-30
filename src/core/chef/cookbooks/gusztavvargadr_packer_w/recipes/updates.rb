options = node['gusztavvargadr_packer_w']
return if options.nil?

gusztavvargadr_packer_w_updates '' do
  updates_options options['updates']
  action :install
end
