options = node['gusztavvargadr_packer_w']
return if options.nil?

gusztavvargadr_packer_w_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
