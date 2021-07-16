directory = File.dirname(__FILE__)

require "#{directory}/../../../../../lib/gusztavvargadr/chef/src/Policyfile"

name 'gusztavvargadr_packer_de'

gusztavvargadr_chef_sources
default_source :chef_repo, "#{directory}/cookbooks"

run_list(
  'recipe[gusztavvargadr_packer_de::default]'
)

named_run_list(
  :prepare,
  'recipe[gusztavvargadr_packer_de::prepare]'
)

named_run_list(
  :install,
  'recipe[gusztavvargadr_packer_de::install]'
)

named_run_list(
  :patch,
  'recipe[gusztavvargadr_packer_de::patch]'
)

named_run_list(
  :cleanup,
  'recipe[gusztavvargadr_packer_de::cleanup]'
)
