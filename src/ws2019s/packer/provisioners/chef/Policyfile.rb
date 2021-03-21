directory = File.dirname(__FILE__)

require "#{directory}/../../../../../lib/gusztavvargadr/chef/src/Policyfile"

name 'gusztavvargadr_packer_ws2019s'

gusztavvargadr_chef_sources
default_source :chef_repo, "#{directory}/cookbooks"

run_list(
  'recipe[gusztavvargadr_packer_ws2019s::default]'
)

named_run_list(
  :prepare,
  'recipe[gusztavvargadr_packer_ws2019s::prepare]'
)

named_run_list(
  :install,
  'recipe[gusztavvargadr_packer_ws2019s::install]'
)

named_run_list(
  :patch,
  'recipe[gusztavvargadr_packer_ws2019s::patch]'
)

named_run_list(
  :cleanup,
  'recipe[gusztavvargadr_packer_ws2019s::cleanup]'
)
