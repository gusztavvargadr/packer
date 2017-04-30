options = node['gusztavvargadr_packer_core']
return if options.nil?

gusztavvargadr_packer_core_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
