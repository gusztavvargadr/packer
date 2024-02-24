require "#{File.dirname(__FILE__)}/../../src/ubuntu/chef/Policyfile"

name 'gusztavvargadr_packer_kitchen_ubuntu'

gusztavvargadr_packer_ubuntu_sources

run_list(
  'recipe[gusztavvargadr_packer_ubuntu::default]',
)
