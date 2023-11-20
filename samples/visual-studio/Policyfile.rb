require "#{File.dirname(__FILE__)}/../../src/windows/chef/Policyfile"

name 'gusztavvargadr_packer_visualstudio'

gusztavvargadr_packer_windows_sources

run_list(
  'recipe[gusztavvargadr_packer_windows::initialize]',
  'recipe[gusztavvargadr_packer_windows::provision]',
  'recipe[gusztavvargadr_packer_windows::deploy]',
  'recipe[gusztavvargadr_visualstudio::default]',
  'recipe[gusztavvargadr_packer_windows::cleanup]'
)
