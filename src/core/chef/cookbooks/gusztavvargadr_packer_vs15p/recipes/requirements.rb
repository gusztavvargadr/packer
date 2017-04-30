options = node['gusztavvargadr_packer_vs15p']
return if options.nil?

gusztavvargadr_packer_vs15p_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
