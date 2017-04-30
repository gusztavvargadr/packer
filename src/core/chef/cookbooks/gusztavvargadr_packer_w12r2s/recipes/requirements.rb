options = node['gusztavvargadr_packer_w12r2s']
return if options.nil?

gusztavvargadr_packer_w12r2s_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
