require "#{File.dirname(__FILE__)}/../../src/windows/chef/Policyfile"

name 'gusztavvargadr_packer_development_windows'

gusztavvargadr_packer_windows_sources

run_list(
  'recipe[gusztavvargadr_packer_windows::initialize]',
  'recipe[gusztavvargadr_packer_windows::apply]',
  'recipe[gusztavvargadr_development::default]',
  'recipe[gusztavvargadr_packer_windows::cleanup]'
)

attributes(
  [
    "#{File.dirname(__FILE__)}/Policyfile.yml",
  ]
)
