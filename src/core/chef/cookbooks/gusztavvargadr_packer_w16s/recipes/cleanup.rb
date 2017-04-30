options = node['gusztavvargadr_packer_w16s']
return if options.nil?

gusztavvargadr_packer_w16s_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
