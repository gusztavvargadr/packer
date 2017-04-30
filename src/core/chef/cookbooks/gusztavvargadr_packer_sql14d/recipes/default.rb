default_options = node['gusztavvargadr_packer_core'].nil? ? nil : node['gusztavvargadr_packer_core']['default']
return if default_options.nil?

include_recipe 'gusztavvargadr_packer_sql14d::requirements' if default_options['requirements']
include_recipe 'gusztavvargadr_packer_sql14d::tools' if default_options['tools']
include_recipe 'gusztavvargadr_packer_sql14d::updates' if default_options['updates']
include_recipe 'gusztavvargadr_packer_sql14d::cleanup' if default_options['cleanup']
