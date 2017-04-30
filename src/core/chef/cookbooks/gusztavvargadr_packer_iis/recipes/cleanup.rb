options = node['gusztavvargadr_packer_iis']
return if options.nil?

gusztavvargadr_packer_iis_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
