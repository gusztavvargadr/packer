directory = File.dirname(__FILE__)

require "#{directory}/src/vagrant"

VagrantMachine.defaults_include(
  'autostart' => false,
  'synced_folders' => {
    '/vagrant' => {
      'disabled' => true,
    },
  },
  'providers' => {
    'virtualbox' => {},
    'hyperv' => {},
  }
)

VagrantProvider.defaults_include(
  'memory' => 4096,
  'cpus' => 2
)

def version
  '1811.0.0'
end

VagrantDeployment.configure(directory, 'environment' => 'packer') do |deployment|
  create_packer_windows_vms(deployment, 'w10e')
  create_packer_windows_vms(deployment, 'w10e-dc')
  create_packer_windows_vms(deployment, 'w10e-dc-vs17c')
  create_packer_windows_vms(deployment, 'w10e-dc-vs17p')

  # create_packer_windows_vms(deployment, 'windows10')
  # create_packer_windows_vms(deployment, 'visualstudio2017')

  create_packer_windows_vms(deployment, 'w16s')
  create_packer_windows_vms(deployment, 'w16s-dc')
  create_packer_windows_vms(deployment, 'w16s-dc-vs17c')
  create_packer_windows_vms(deployment, 'w16s-dc-vs17p')
  create_packer_windows_vms(deployment, 'w16s-iis')
  create_packer_windows_vms(deployment, 'w16s-sql14d')
  create_packer_windows_vms(deployment, 'w16s-sql17d')

  # create_packer_windows_vms(deployment, 'windowsserver2016')

  # create_packer_windows_vms(deployment, 'w16s-vs17c')
  # create_packer_windows_vms(deployment, 'w16s-vs17p')
  # create_packer_windows_vms(deployment, 'w16s-de')

  create_packer_windows_vms(deployment, 'w16sc')
  create_packer_windows_vms(deployment, 'w16sc-de')

  # create_packer_windows_vms(deployment, 'windowsservercore2016')

  create_packer_windows_vms(deployment, 'w1809de')
  create_packer_windows_vms(deployment, 'w1809de-dc')
  create_packer_windows_vms(deployment, 'w1809de-dc-vs17c')
  create_packer_windows_vms(deployment, 'w1809de-dc-vs17p')

  create_packer_windows_vms(deployment, 'w1809ss')
  create_packer_windows_vms(deployment, 'w1809ss-dc')
  create_packer_windows_vms(deployment, 'w1809ss-dc-vs17c')
  create_packer_windows_vms(deployment, 'w1809ss-dc-vs17p')

  create_packer_windows_vms(deployment, 'w1809ssc')
  create_packer_windows_vms(deployment, 'w1809ssc-de')

  create_packer_linux_vms(deployment, 'u16s')
  create_packer_linux_vms(deployment, 'u16s-dc')

  create_packer_linux_vms(deployment, 'u16d')
  create_packer_linux_vms(deployment, 'u16d-dc')

  # create_packer_linux_vms(deployment, 'ubuntuserver16')
  # create_packer_linux_vms(deployment, 'ubuntudesktop16')
end

def create_packer_windows_vms(deployment, name)
  create_local_packer_vm(deployment, name, 'sysprep')
  create_cloud_packer_vm(deployment, name)
end

def create_packer_linux_vms(deployment, name)
  create_local_packer_vm(deployment, name)
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
