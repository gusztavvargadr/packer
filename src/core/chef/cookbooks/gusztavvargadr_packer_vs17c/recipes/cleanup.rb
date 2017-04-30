options = node['gusztavvargadr_packer_vs17c']
return if options.nil?

gusztavvargadr_packer_vs17c_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
