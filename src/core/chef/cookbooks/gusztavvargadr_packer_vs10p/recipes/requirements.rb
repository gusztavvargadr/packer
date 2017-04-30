options = node['gusztavvargadr_packer_vs10p']
return if options.nil?

gusztavvargadr_packer_vs10p_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
