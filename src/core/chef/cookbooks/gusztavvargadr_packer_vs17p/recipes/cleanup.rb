options = node['gusztavvargadr_packer_vs17p']
return if options.nil?

gusztavvargadr_packer_vs17p_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
