options = node['gusztavvargadr_packer_vs10p']
return if options.nil?

gusztavvargadr_packer_vs10p_tools '' do
  tools_options options['tools']
  action :install
end
