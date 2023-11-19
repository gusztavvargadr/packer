require "#{File.dirname(__FILE__)}/../../src/windows/chef/Policyfile"

name 'gusztavvargadr_packer_sql_server'

gusztavvargadr_packer_windows_sources

run_list(
  'recipe[gusztavvargadr_packer_windows::initialize]',
  'recipe[gusztavvargadr_packer_windows::provision]',
  'recipe[gusztavvargadr_packer_windows::deploy]',
  'recipe[gusztavvargadr_mssql::default]',
  'recipe[gusztavvargadr_packer_windows::cleanup]'
)

attributes(
  [
    "#{File.dirname(__FILE__)}/Policyfile.yml",
  ]
)
