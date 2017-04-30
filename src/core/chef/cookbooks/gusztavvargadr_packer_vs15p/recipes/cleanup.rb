options = node['gusztavvargadr_packer_vs15p']
return if options.nil?

gusztavvargadr_packer_vs15p_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
