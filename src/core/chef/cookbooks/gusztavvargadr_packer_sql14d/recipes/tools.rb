options = node['gusztavvargadr_packer_sql14d']
return if options.nil?

gusztavvargadr_packer_sql14d_tools '' do
  tools_options options['tools']
  action :install
end
