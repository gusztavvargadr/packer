options = node['gusztavvargadr_packer_virtualbox']
return if options.nil?

gusztavvargadr_packer_virtualbox_updates '' do
  updates_options options['updates']
  action :install
end
