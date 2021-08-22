directory = File.dirname(__FILE__)

require "#{directory}/../../../../../lib/gusztavvargadr/chef/src/Policyfile"

name 'gusztavvargadr_packer_vs17c'

gusztavvargadr_chef_sources
default_source :chef_repo, "#{directory}/cookbooks"

run_list(
  'recipe[gusztavvargadr_packer_vs17c::default]'
)

named_run_list(
  :prepare,
  'recipe[gusztavvargadr_packer_vs17c::prepare]'
)

named_run_list(
  :install,
  'recipe[gusztavvargadr_packer_vs17c::install]'
)

named_run_list(
  :patch,
  'recipe[gusztavvargadr_packer_vs17c::patch]'
)

named_run_list(
  :cleanup,
  'recipe[gusztavvargadr_packer_vs17c::cleanup]'
)
