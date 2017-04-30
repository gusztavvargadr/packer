options = node['gusztavvargadr_packer_vs10p']
return if options.nil?

gusztavvargadr_packer_vs10p_updates '' do
  updates_options options['updates']
  action :install
end
