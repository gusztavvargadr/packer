options = node['gusztavvargadr_packer_vs15c']
return if options.nil?

gusztavvargadr_packer_vs15c_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
