options = node['gusztavvargadr_packer_sql14d']
return if options.nil?

gusztavvargadr_packer_sql14d_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
