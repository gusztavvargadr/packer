directory = File.dirname(__FILE__)

require "#{directory}/src/vagrant"

VagrantMachine.defaults_include(
  'autostart' => false,
  'providers' => {
    'virtualbox' => {},
    'hyperv' => {},
  },
  'provisioners' => {
    'shell' => {
      'inline' => 'echo "Hello World!"',
    },
  }
)

VagrantVirtualBoxProvider.defaults_include(
  'memory' => 4096,
  'cpus' => 2
)

VagrantHyperVProvider.defaults_include(
  'memory' => 4096,
  'cpus' => 2
)

def version
  '1905'
end

VagrantDeployment.configure(directory, 'stack' => 'packer') do |deployment|
  create_packer_vms(deployment, 'w10e', 'windows-10', "1809.0.#{version}-enterprise")

  create_packer_vms(deployment, 'ws2019s', 'windows-server', "1809.0.#{version}-standard")
  create_packer_vms(deployment, 'ws2019sc', 'windows-server', "1809.0.#{version}-standard-core")

  create_packer_vms(deployment, 'u16d', 'ubuntu-desktop', "1604.0.#{version}-lts")

  create_packer_vms(deployment, 'u16s', 'ubuntu-server', "1604.0.#{version}-lts")

  create_packer_vms(deployment, 'ws2019sc-de', 'docker-windows', "1809.0.#{version}-enterprise-windows-server-1809-standard-core")

  create_packer_vms(deployment, 'u16s-dc', 'docker-linux', "1809.0.#{version}-community-ubuntu-server-1604-lts")

  create_packer_vms(deployment, 'ws2019s-iis', 'iis', "10.0.#{version}-windows-server-1809-standard")

  create_packer_vms(deployment, 'ws2019s-sql17d', 'sql-server', "2017.0.#{version}-developer-windows-server-1809-standard")

  create_packer_vms(deployment, 'w10e-dc-vs17c', 'visual-studio', "2017.0.#{version}-community-windows-10-1809-enterprise")
  create_packer_vms(deployment, 'w10e-dc-vs17p', 'visual-studio', "2017.0.#{version}-professional-windows-10-1809-enterprise")
  create_packer_vms(deployment, 'w10e-dc-vs19c', 'visual-studio', "2019.0.#{version}-community-windows-10-1809-enterprise")
  create_packer_vms(deployment, 'w10e-dc-vs19p', 'visual-studio', "2019.0.#{version}-professional-windows-10-1809-enterprise")

  create_packer_vms(deployment, 'ws2019s-dc-vs17c', 'visual-studio', "2017.0.#{version}-community-windows-server-1809-standard")
  create_packer_vms(deployment, 'ws2019s-dc-vs17p', 'visual-studio', "2017.0.#{version}-professional-windows-server-1809-standard")
  create_packer_vms(deployment, 'ws2019s-dc-vs19c', 'visual-studio', "2019.0.#{version}-community-windows-server-1809-standard")
  create_packer_vms(deployment, 'ws2019s-dc-vs19p', 'visual-studio', "2019.0.#{version}-professional-windows-server-1809-standard")
end

def create_packer_vms(deployment, name, cloud_name, cloud_version)
  create_local_packer_vm(deployment, name, 'sysprep')
  create_cloud_packer_vm(deployment, name, cloud_name, cloud_version)
end

def create_local_packer_vm(deployment, name, type)
  VagrantMachine.configure(deployment, 'name' => "#{name}-local", 'box' => "gusztavvargadr/#{name}-local") do |machine|
    VagrantVirtualBoxProvider.configure(machine) do |provider|
      provider.override.vm.box_url = "file://#{File.dirname(__FILE__)}/build/#{name}/virtualbox-#{type}/output/vagrant.box"
    end

    VagrantHyperVProvider.configure(machine) do |provider|
      provider.override.vm.box_url = "file://#{File.dirname(__FILE__)}/build/#{name}/hyperv-#{type}/output/vagrant.box"
    end
  end
end

def create_cloud_packer_vm(deployment, name, cloud_name, cloud_version)
  VagrantMachine.configure(deployment, 'name' => "#{name}-cloud", 'box' => "gusztavvargadr/#{name}-cloud") do |machine|
    machine.vagrant.vm.box = "gusztavvargadr/#{cloud_name}"
    machine.vagrant.vm.box_version = cloud_version

    # VagrantVirtualBoxProvider.configure(machine) do |provider|
    #   provider.override.vm.box_url = "https://vagrantcloud.com/gusztavvargadr/boxes/#{cloud_name}/versions/#{cloud_version}/providers/virtualbox.box"
    # end

    # VagrantHyperVProvider.configure(machine) do |provider|
    #   provider.override.vm.box_url = "https://vagrantcloud.com/gusztavvargadr/boxes/#{cloud_name}/versions/#{cloud_version}/providers/hyperv.box"
    # end
  end
end
