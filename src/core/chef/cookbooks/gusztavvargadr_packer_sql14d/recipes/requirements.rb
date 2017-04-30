options = node['gusztavvargadr_packer_sql14d']
return if options.nil?

gusztavvargadr_packer_sql14d_requirements '' do
  requirements_options options['requirements']
  action :ensure
end
