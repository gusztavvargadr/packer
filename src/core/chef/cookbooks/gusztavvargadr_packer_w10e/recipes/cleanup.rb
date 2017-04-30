options = node['gusztavvargadr_packer_w10e']
return if options.nil?

gusztavvargadr_packer_w10e_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
