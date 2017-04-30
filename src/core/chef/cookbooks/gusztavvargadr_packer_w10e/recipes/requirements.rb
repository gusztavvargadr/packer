options = node['gusztavvargadr_packer_w10e']
return if options.nil?

gusztavvargadr_packer_w10e_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
