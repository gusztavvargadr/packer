options = node['gusztavvargadr_packer_sql14d']
return if options.nil?

gusztavvargadr_packer_sql14d_updates '' do
  updates_options options['updates']
  action :install
end
