options = node['gusztavvargadr_packer_vs10p']
return if options.nil?

gusztavvargadr_packer_vs10p_cleanup '' do
  cleanup_options options['cleanup']
  action :run
end
