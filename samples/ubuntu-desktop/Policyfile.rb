require "#{File.dirname(__FILE__)}/../../src/ubuntu/chef/Policyfile"

name 'gusztavvargadr_packer_ubuntu_desktop'

gusztavvargadr_packer_ubuntu_sources

run_list(
  'recipe[gusztavvargadr_packer_ubuntu::initialize]',
  'recipe[gusztavvargadr_packer_ubuntu::provision]',
  'recipe[gusztavvargadr_packer_ubuntu::deploy]',
  'recipe[gusztavvargadr_ubuntu::default]',
  'recipe[gusztavvargadr_packer_ubuntu::cleanup]'
)
