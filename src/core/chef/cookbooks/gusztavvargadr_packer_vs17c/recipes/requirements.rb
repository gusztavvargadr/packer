options = node['gusztavvargadr_packer_vs17c']
return if options.nil?

gusztavvargadr_packer_vs17c_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
