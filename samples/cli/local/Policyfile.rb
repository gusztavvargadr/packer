directory = File.dirname(__FILE__)

require "#{directory}/../../../lib/gusztavvargadr/chef/src/Policyfile"

name 'cli'

gusztavvargadr_chef_sources

cookbook 'gusztavvargadr_windows'

run_list 'recipe[gusztavvargadr_windows::environment_variables]', 'recipe[gusztavvargadr_windows::chocolatey_packages]'

attributes "#{directory}/Policyfile.yml"
