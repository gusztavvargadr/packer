require "#{File.dirname(__FILE__)}/../../src/ubuntu/chef/Policyfile"

name 'gusztavvargadr_packer_development_ubuntu'

gusztavvargadr_packer_ubuntu_sources

run_list(
  'recipe[gusztavvargadr_packer_ubuntu::initialize]',
  'recipe[gusztavvargadr_packer_ubuntu::apply]',
  'recipe[gusztavvargadr_development::default]',
  'recipe[gusztavvargadr_chef::default]',
  'recipe[gusztavvargadr_packer_ubuntu::cleanup]'
)

attributes(
  [
    "#{File.dirname(__FILE__)}/Policyfile.yml",
  ]
)
