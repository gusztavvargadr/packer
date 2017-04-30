options = node['gusztavvargadr_packer_core']
return if options.nil?

gusztavvargadr_packer_core_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
