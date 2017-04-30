options = node['gusztavvargadr_packer_vs15p']
return if options.nil?

gusztavvargadr_packer_vs15p_updates '' do
  updates_options options['updates']
  action :install
end
