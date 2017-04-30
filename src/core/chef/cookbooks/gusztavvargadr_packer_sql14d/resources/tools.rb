property :tools_options, Hash

default_action :install

action :install do
  return if tools_options.nil?

  gusztavvargadr_packer_core_tools '' do
    tools_options new_resource.tools_options
    action :install
  end

  gusztavvargadr_packer_sql_2014 'developer' do
    action :install
  end
end
