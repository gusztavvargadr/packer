options = node['gusztavvargadr_packer_vs17p']
return if options.nil?

gusztavvargadr_packer_vs17p_tools '' do
  tools_options options['tools']
  action :install
end
