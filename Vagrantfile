directory = File.dirname(__FILE__)

require "#{directory}/src/vagrant"

def version
  '2003'
end

VagrantMachine.defaults_include(
  'autostart' => false,
)

class VagrantWindowsMachine < VagrantMachine
  @defaults = {
    'providers' => {
      'virtualbox' => {
        'memory' => 4096,
        'cpus' => 2,
      },
      'hyperv' => {
        'memory' => 4096,
        'cpus' => 2,
      },
    },
    'provisioners' => {
      'shell-os' => {
        'inline' => 'cmd /c ver',
      },
      'shell-system' => {
        'inline' => 'systeminfo',
      },
      'shell-packages' => {
        'inline' => 'choco list -li',
      },
      'chef_policyfile' => {
        'paths' => [
          'Policyfile.rb',
        ],
      },
    }
  }
end

class VagrantLinuxMachine < VagrantMachine
  @defaults = {
    'providers' => {
      'virtualbox' => {
        'memory' => 4096,
        'cpus' => 2,
      },
      'hyperv' => {
        'memory' => 4096,
        'cpus' => 2,
      },
    },
    'provisioners' => {
      'shell-os' => {
        'inline' => 'uname -a',
      },
      'shell-system' => {
        'inline' => 'lshw',
      },
      'shell-packages' => {
        'inline' => 'apt list --installed',
      },
      'chef_policyfile' => {
        'paths' => [
          'Policyfile.rb',
        ],
      },
    }
  }
end

VagrantDeployment.configure(directory, 'stack' => 'packer') do |deployment|
  create_packer_vms(deployment, 'ws2016s', 'windows-server', "1607.0.#{version}-standard")
  create_packer_vms(deployment, 'ws2016sc', 'windows-server', "1607.0.#{version}-standard-core")
  create_packer_vms(deployment, 'ws2019s', 'windows-server', "1809.0.#{version}-standard")
  create_packer_vms(deployment, 'ws2019sc', 'windows-server', "1809.0.#{version}-standard-core")

  create_packer_vms(deployment, 'w10e', 'windows-10', "1909.0.#{version}-enterprise")

  create_packer_vms(deployment, 'u16s', 'ubuntu-server', "1604.0.#{version}-lts")

  create_packer_vms(deployment, 'u16d', 'ubuntu-desktop', "1604.0.#{version}-lts")

  create_packer_vms(deployment, 'w10e-dc', 'docker-windows', "1903.0.#{version}-community-windows-10-1909-enterprise")
  create_packer_vms(deployment, 'ws2019s-dc', 'docker-windows', "1903.0.#{version}-community-windows-server-1809-standard")
  create_packer_vms(deployment, 'ws2016s-de', 'docker-windows', "1903.0.#{version}-enterprise-windows-server-1607-standard")
  create_packer_vms(deployment, 'ws2016sc-de', 'docker-windows', "1903.0.#{version}-enterprise-windows-server-1607-standard-core")
  create_packer_vms(deployment, 'ws2019s-de', 'docker-windows', "1903.0.#{version}-enterprise-windows-server-1809-standard")
  create_packer_vms(deployment, 'ws2019sc-de', 'docker-windows', "1903.0.#{version}-enterprise-windows-server-1809-standard-core")

  create_packer_vms(deployment, 'u16s-dc', 'docker-linux', "1903.0.#{version}-community-ubuntu-server-1604-lts")
  create_packer_vms(deployment, 'u16d-dc', 'docker-linux', "1903.0.#{version}-community-ubuntu-desktop-1604-lts")

  create_packer_vms(deployment, 'ws2016s-iis', 'iis', "10.0.#{version}-windows-server-1607-standard")
  create_packer_vms(deployment, 'ws2016sc-iis', 'iis', "10.0.#{version}-windows-server-1607-standard-core")
  create_packer_vms(deployment, 'ws2019s-iis', 'iis', "10.0.#{version}-windows-server-1809-standard")
  create_packer_vms(deployment, 'ws2019sc-iis', 'iis', "10.0.#{version}-windows-server-1809-standard-core")

  create_packer_vms(deployment, 'ws2019s-sql17d', 'sql-server', "2017.0.#{version}-developer-windows-server-1809-standard")
  create_packer_vms(deployment, 'ws2019s-sql19d', 'sql-server', "2019.0.#{version}-developer-windows-server-1809-standard")

  create_packer_vms(deployment, 'w10e-dc-vs17c', 'visual-studio', "2017.0.#{version}-community-windows-10-1909-enterprise")
  create_packer_vms(deployment, 'w10e-dc-vs17p', 'visual-studio', "2017.0.#{version}-professional-windows-10-1909-enterprise")
  create_packer_vms(deployment, 'w10e-dc-vs19c', 'visual-studio', "2019.0.#{version}-community-windows-10-1909-enterprise")
  create_packer_vms(deployment, 'w10e-dc-vs19p', 'visual-studio', "2019.0.#{version}-professional-windows-10-1909-enterprise")
  create_packer_vms(deployment, 'ws2019s-dc-vs17c', 'visual-studio', "2017.0.#{version}-community-windows-server-1809-standard")
  create_packer_vms(deployment, 'ws2019s-dc-vs17p', 'visual-studio', "2017.0.#{version}-professional-windows-server-1809-standard")
  create_packer_vms(deployment, 'ws2019s-dc-vs19c', 'visual-studio', "2019.0.#{version}-community-windows-server-1809-standard")
  create_packer_vms(deployment, 'ws2019s-dc-vs19p', 'visual-studio', "2019.0.#{version}-professional-windows-server-1809-standard")
end

def create_packer_vms(deployment, name, cloud_name, cloud_version)
  create_build_packer_vm(deployment, name)
  create_deploy_packer_vm(deployment, name, cloud_name, cloud_version)
end

def create_build_packer_vm(deployment, name)
  VagrantMachine.configure(deployment, create_machine_class(name).defaults.merge('name' => "#{name}-build", 'box' => "local/gusztavvargadr/#{name}-build")) do |machine|
    VagrantVirtualBoxProvider.configure(machine, machine.options.fetch('providers').fetch('virtualbox')) do |provider|
      provider.override.vm.box_url = "file://#{build_dir}/#{name}/virtualbox-vagrant/output/package/vagrant.box"
    end

    VagrantHyperVProvider.configure(machine, machine.options.fetch('providers').fetch('hyperv')) do |provider|
      provider.override.vm.box_url = "file://#{build_dir}/#{name}/hyperv-vagrant/output/package/vagrant.box"
    end
  end
end

def create_deploy_packer_vm(deployment, name, cloud_name, cloud_version)
  VagrantMachine.configure(deployment, create_machine_class(name).defaults.merge('name' => "#{name}-deploy", 'box' => "local/gusztavvargadr/#{name}-deploy")) do |machine|
    VagrantVirtualBoxProvider.configure(machine, machine.options.fetch('providers').fetch('virtualbox')) do |provider|
      provider.override.vm.box_url = "https://vagrantcloud.com/gusztavvargadr/boxes/#{cloud_name}/versions/#{cloud_version}/providers/virtualbox.box"
    end

    VagrantHyperVProvider.configure(machine, machine.options.fetch('providers').fetch('hyperv')) do |provider|
      provider.override.vm.box_url = "https://vagrantcloud.com/gusztavvargadr/boxes/#{cloud_name}/versions/#{cloud_version}/providers/hyperv.box"
    end
  end
end

def create_machine_class(name)
  class_name = name.include?('u16') ? 'VagrantLinuxMachine' : 'VagrantWindowsMachine'
  Object.const_get(class_name)
end

def build_dir
  ENV['PACKER_BUILD_DIR'] ? ENV['PACKER_BUILD_DIR'] : "#{File.dirname(__FILE__)}/build"
end
