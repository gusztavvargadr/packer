source 'https://supermarket.chef.io'

def gusztavvargadr_packer_cookbook(name, directory)
  cookbook "gusztavvargadr_packer_#{name}", path: "#{directory}/cookbooks/gusztavvargadr_packer_#{name}"
end

def gusztavvargadr_cookbook(name)
  cookbook "gusztavvargadr_#{name}", github: 'gusztavvargadr/chef', rel: "cookbooks/gusztavvargadr_#{name}", branch: '0.2.2'
end

gusztavvargadr_packer_cookbook 'virtualbox', local_directory
gusztavvargadr_packer_cookbook 'os', local_directory
gusztavvargadr_packer_cookbook 'core', local_directory

gusztavvargadr_cookbook 'windows'
