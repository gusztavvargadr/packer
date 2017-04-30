options = node['gusztavvargadr_packer_w']
return if options.nil?

gusztavvargadr_packer_w_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
