require "#{File.dirname(__FILE__)}/../../../lib/gusztavvargadr/chef/src/Policyfile"

def gusztavvargadr_packer_windows_sources
  gusztavvargadr_chef_sources
  default_source :chef_repo, "#{File.dirname(__FILE__)}/cookbooks"
end
