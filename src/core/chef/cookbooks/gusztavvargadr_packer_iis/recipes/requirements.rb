options = node['gusztavvargadr_packer_iis']
return if options.nil?

gusztavvargadr_packer_iis_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
