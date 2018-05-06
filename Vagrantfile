require "#{File.dirname(__FILE__)}/lib/gusztavvargadr/infrastructure/src/components/core/vagrant/Vagrantfile.core"

Environment.new(name: 'packer.local') do |environment|
  create_packer_windows_vms(environment, 'w10e')
  create_packer_windows_vms(environment, 'w10e-dc')
  create_packer_windows_vms(environment, 'w10e-vs17c')

  create_packer_windows_vms(environment, 'w16s')
  create_packer_windows_vms(environment, 'w16s-de')
  create_packer_windows_vms(environment, 'w16s-iis')
  create_packer_windows_vms(environment, 'w16s-sql14d')
  create_packer_windows_vms(environment, 'w16s-sql17d')

  create_packer_windows_vms(environment, 'w16sc')
  create_packer_windows_vms(environment, 'w16sc-de')

  create_packer_linux_vms(environment, 'u16s')
  create_packer_linux_vms(environment, 'u16s-dc')
end

def create_packer_windows_vms(environment, name)
  create_local_packer_vm(environment, name, 'core')
  create_local_packer_vm(environment, name, 'sysprep')

  create_atlas_packer_vm(environment, name)
end

def create_packer_linux_vms(environment, name)
  create_local_packer_vm(environment, name)

  create_atlas_packer_vm(environment, name)
end

def create_local_packer_vm(environment, name, type = '')
  type_suffix = type.to_s.empty? ? '' : "-#{type}"

  PackerVM.new(environment, name: "#{name}-local#{type_suffix}", box: "gusztavvargadr/#{name}-local#{type_suffix}") do |vm|
    VirtualBoxProvider.new(vm) do |provider|
      provider.override.vm.box_url = "file://#{File.dirname(__FILE__)}/build/#{name}/virtualbox#{type_suffix}/output/vagrant.box"
    end

    HyperVProvider.new(vm) do |provider|
      provider.override.vm.box_url = "file://#{File.dirname(__FILE__)}/build/#{name}/hyperv#{type_suffix}/output/vagrant.box"

      provider.vagrant.differencing_disk = true
      provider.vagrant.enable_virtualization_extensions = true
    end

    ChefSoloProvisioner.new(vm, 'run_list' => 'hello_world::default')
  end
end

def create_atlas_packer_vm(environment, name)
  PackerVM.new(environment, name: name, box: "gusztavvargadr/#{name}") do |vm|
    VirtualBoxProvider.new(vm)

    HyperVProvider.new(vm) do |provider|
      provider.vagrant.differencing_disk = true
      provider.vagrant.enable_virtualization_extensions = true
    end

    ChefSoloProvisioner.new(vm, 'run_list' => 'hello_world::default')
  end
end

class PackerVM < VM
  @@packer = {
    autostart: false,
    memory: 4096,
    cpus: 2,
    linked_clone: false,
  }

  def self.packer(options = {})
    @@packer = @@packer.deep_merge(options)
  end

  def initialize(environment, options = {})
    super(environment, @@packer.deep_merge(options))
  end
end
