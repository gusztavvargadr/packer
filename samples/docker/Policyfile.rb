require "#{File.dirname(__FILE__)}/../../src/windows/chef/Policyfile"

name 'gusztavvargadr_packer_windows_docker'

gusztavvargadr_packer_windows_sources

run_list(
  'recipe[gusztavvargadr_packer_windows::prepare]',
  'recipe[gusztavvargadr_packer_windows::install]',
  'recipe[gusztavvargadr_packer_windows::patch]',
  'recipe[gusztavvargadr_docker::default]',
  'recipe[gusztavvargadr_packer_windows::cleanup]'
)

attributes(
  [
    "#{File.dirname(__FILE__)}/Policyfile.yml",
  ]
)
