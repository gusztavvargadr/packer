require "#{File.dirname(__FILE__)}/lib/gusztavvargadr/chef/src/berkshelf"

def gusztavvargadr_packer_sources
  gusztavvargadr_chef_sources

  gusztavvargadr_chef_cookbook 'windows'
  gusztavvargadr_chef_cookbook 'docker'
  gusztavvargadr_chef_cookbook 'visualstudio'
  gusztavvargadr_chef_cookbook 'iis'
  gusztavvargadr_chef_cookbook 'mssql'

  gusztavvargadr_packer_cookbook 'w'
  gusztavvargadr_packer_cookbook 'w10e'
  gusztavvargadr_packer_cookbook 'w16s'
  gusztavvargadr_packer_cookbook 'w16sc'
  gusztavvargadr_packer_cookbook 'w1809de'
  gusztavvargadr_packer_cookbook 'w1809ss'
  gusztavvargadr_packer_cookbook 'w1809ssc'

  gusztavvargadr_packer_cookbook 'dc'
  gusztavvargadr_packer_cookbook 'de'
  gusztavvargadr_packer_cookbook 'vs17c'
  gusztavvargadr_packer_cookbook 'vs17p'
  gusztavvargadr_packer_cookbook 'iis'
  gusztavvargadr_packer_cookbook 'sql14d'
  gusztavvargadr_packer_cookbook 'sql17d'
end

def gusztavvargadr_packer_cookbook(name)
  cookbook "gusztavvargadr_packer_#{name}", path: "#{File.dirname(__FILE__)}/src/#{name}/chef/cookbooks/gusztavvargadr_packer_#{name}"
end
