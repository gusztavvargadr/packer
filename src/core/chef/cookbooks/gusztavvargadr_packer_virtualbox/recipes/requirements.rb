options = node['gusztavvargadr_packer_virtualbox']
return if options.nil?

gusztavvargadr_packer_virtualbox_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
