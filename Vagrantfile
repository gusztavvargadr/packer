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

VagrantProvider.defaults_include(
  'memory' => 4096,
  'cpus' => 2
)

def version
  '1901.0.0'
end

VagrantDeployment.configure(directory, 'stack' => 'packer') do |deployment|
  # windows-10
  create_packer_windows_vms(deployment, 'w10e')

  # windows-server
  create_packer_windows_vms(deployment, 'ws2019s')
  create_packer_windows_vms(deployment, 'ws2019sc')

  # ubuntu-desktop
  create_packer_linux_vms(deployment, 'u16d')

  # ubuntu-server
  create_packer_linux_vms(deployment, 'u16s')

  # docker-windows
  create_packer_windows_vms(deployment, 'ws2019sc-de')

  # docker-linux
  create_packer_linux_vms(deployment, 'u16s-dc')

  # iis
  create_packer_windows_vms(deployment, 'ws2019s-iis')

  # sql-server
  create_packer_windows_vms(deployment, 'ws2019s-sql17d')

  # visual-studio
  create_packer_windows_vms(deployment, 'w10e-dc-vs17c')
  create_packer_windows_vms(deployment, 'w10e-dc-vs17p')

  create_packer_windows_vms(deployment, 'ws2019s-dc-vs17c')
  create_packer_windows_vms(deployment, 'ws2019s-dc-vs17p')
end

def create_packer_windows_vms(deployment, name)
  create_local_packer_vm(deployment, name, 'sysprep')
  create_cloud_packer_vm(deployment, name)
end

def create_packer_linux_vms(deployment, name)
  create_local_packer_vm(deployment, name, 'sysprep')
  create_cloud_packer_vm(deployment, name)
end

def create_local_packer_vm(deployment, name, type = '')
  type_suffix = type.to_s.empty? ? '' : "-#{type}"

  VagrantMachine.configure(deployment, 'name' => "#{name}-local", 'box' => "gusztavvargadr/#{name}-local") do |machine|
    VagrantVirtualBoxProvider.configure(machine) do |provider|
      provider.override.vm.box_url = "file://#{File.dirname(__FILE__)}/build/#{name}/virtualbox#{type_suffix}/output/vagrant.box"
    end

    VagrantHyperVProvider.configure(machine) do |provider|
      provider.override.vm.box_url = "file://#{File.dirname(__FILE__)}/build/#{name}/hyperv#{type_suffix}/output/vagrant.box"
    end
  end
end

def create_cloud_packer_vm(deployment, name)
  VagrantMachine.configure(deployment, 'name' => "#{name}-cloud", 'box' => "gusztavvargadr/#{name}-cloud") do |machine|
    VagrantVirtualBoxProvider.configure(machine) do |provider|
      provider.override.vm.box_url = "https://vagrantcloud.com/gusztavvargadr/boxes/#{name}/versions/#{version}/providers/virtualbox.box"
    end

    VagrantHyperVProvider.configure(machine) do |provider|
      provider.override.vm.box_url = "https://vagrantcloud.com/gusztavvargadr/boxes/#{name}/versions/#{version}/providers/hyperv.box"
    end
  end
end
