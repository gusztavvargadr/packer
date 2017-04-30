options = node['gusztavvargadr_packer_os']
return if options.nil?

gusztavvargadr_packer_os_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
