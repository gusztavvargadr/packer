require "#{File.dirname(__FILE__)}/../../src/windows/chef/Policyfile"

name 'gusztavvargadr_packer_kitchen_windows'

gusztavvargadr_packer_windows_sources

run_list(
  'recipe[gusztavvargadr_packer_windows::default]',
)
