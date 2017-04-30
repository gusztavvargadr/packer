options = node['gusztavvargadr_packer_vs17p']
return if options.nil?

gusztavvargadr_packer_vs17p_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
