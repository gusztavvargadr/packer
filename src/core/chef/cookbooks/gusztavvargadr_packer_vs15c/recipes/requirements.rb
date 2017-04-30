options = node['gusztavvargadr_packer_vs15c']
return if options.nil?

gusztavvargadr_packer_vs15c_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
