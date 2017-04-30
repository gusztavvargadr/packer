options = node['gusztavvargadr_packer_w16s']
return if options.nil?

gusztavvargadr_packer_w16s_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
