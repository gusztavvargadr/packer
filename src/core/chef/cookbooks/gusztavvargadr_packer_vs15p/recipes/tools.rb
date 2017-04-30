options = node['gusztavvargadr_packer_vs15p']
return if options.nil?

gusztavvargadr_packer_vs15p_tools '' do
  tools_options options['tools']
  action :install
end
