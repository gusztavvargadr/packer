options = node['gusztavvargadr_packer_w12r2s']
return if options.nil?

gusztavvargadr_packer_w12r2s_updates '' do
  updates_options options['updates']
  action :install
end
