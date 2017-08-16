directory = File.dirname(__FILE__)
require "#{directory}/lib/gusztavvargadr/infrastructure/src/components/core/chef/Berksfile.core"

def gusztavvargadr_packer_sources
  gusztavvargadr_sources

  gusztavvargadr_packer_cookbook 'w'
  gusztavvargadr_packer_cookbook 'w', 'hyperv_iso'
  gusztavvargadr_packer_cookbook 'w', 'virtualbox_iso'
  gusztavvargadr_packer_cookbook 'w', 'virtualbox_ovf'
  gusztavvargadr_packer_cookbook 'w', 'amazon_ebs'

  gusztavvargadr_packer_cookbook 'w10e'
  gusztavvargadr_packer_cookbook 'w16s'
  gusztavvargadr_packer_cookbook 'dc'
  gusztavvargadr_packer_cookbook 'iis'
  gusztavvargadr_packer_cookbook 'sql14x'
  gusztavvargadr_packer_cookbook 'sql14d'
  gusztavvargadr_packer_cookbook 'vs10p'
  gusztavvargadr_packer_cookbook 'vs15c'
  gusztavvargadr_packer_cookbook 'vs15p'
  gusztavvargadr_packer_cookbook 'vs17c'
  gusztavvargadr_packer_cookbook 'vs17p'

  gusztavvargadr_cookbook 'components', 'windows'
  gusztavvargadr_cookbook 'components', 'virtualbox'
  gusztavvargadr_cookbook 'components', 'docker'
  gusztavvargadr_cookbook 'components', 'iis'
  gusztavvargadr_cookbook 'components', 'sql'
  gusztavvargadr_cookbook 'components', 'vs'
end

def gusztavvargadr_packer_cookbook(type, name = '')
  name = type if name.empty?
  cookbook "gusztavvargadr_packer_#{name}", path: "#{File.dirname(__FILE__)}/src/#{type}/chef/cookbooks/gusztavvargadr_packer_#{name}"
end
