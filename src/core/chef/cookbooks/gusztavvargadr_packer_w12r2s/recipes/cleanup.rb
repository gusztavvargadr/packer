options = node['gusztavvargadr_packer_w12r2s']
return if options.nil?

gusztavvargadr_packer_w12r2s_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
