directory = File.dirname(__FILE__)

require "#{directory}/../../../../../lib/gusztavvargadr/chef/src/Policyfile"

name 'gusztavvargadr_packer_dc'

gusztavvargadr_chef_sources
default_source :chef_repo, "#{directory}/cookbooks"

run_list(
  'recipe[gusztavvargadr_packer_dc::default]'
)

named_run_list(
  :prepare,
  'recipe[gusztavvargadr_packer_dc::prepare]'
)

named_run_list(
  :install,
  'recipe[gusztavvargadr_packer_dc::install]'
)

named_run_list(
  :patch,
  'recipe[gusztavvargadr_packer_dc::patch]'
)

named_run_list(
  :cleanup,
  'recipe[gusztavvargadr_packer_dc::cleanup]'
)
