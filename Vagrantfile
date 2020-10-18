directory = File.dirname(__FILE__)

require "#{directory}/src/vagrant"

def version
  '2010'
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
      'shell' => {
        'inline' => <<-EOF
          cmd /c ver
          Get-ComputerInfo
          choco list -li
        EOF
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
      'shell' => {
        'inline' => <<-EOF
          uname -a
          lshw
          apt list --installed
        EOF
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
  create_machine(deployment, 'ws2016s')
  create_machine(deployment, 'ws2019s')
  create_machine(deployment, 'ws2016sc')
  create_machine(deployment, 'ws2019sc')
  create_machine(deployment, 'wsipsc')

  create_machine(deployment, 'w101809eltsc')
  create_machine(deployment, 'w101909e')
  create_machine(deployment, 'w102004e')
  create_machine(deployment, 'w10ipe')

  create_machine(deployment, 'u1604s')

  create_machine(deployment, 'u1604d')

  create_machine(deployment, 'ws2019s-de')
  create_machine(deployment, 'ws2019sc-de')

  create_machine(deployment, 'w102004e-dc')
  create_machine(deployment, 'u1604s-dc')
  create_machine(deployment, 'u1604d-dc')

  create_machine(deployment, 'ws2019s-iis')
  create_machine(deployment, 'ws2019sc-iis')

  create_machine(deployment, 'ws2019s-sql17d')
  create_machine(deployment, 'ws2019s-sql19d')

  create_machine(deployment, 'w102004e-dc-vs17c')
  create_machine(deployment, 'w102004e-dc-vs19c')
  create_machine(deployment, 'w102004e-dc-vs17p')
  create_machine(deployment, 'w102004e-dc-vs19p')
end

def create_machine(deployment, name)
  VagrantMachine.configure(deployment, create_machine_class(name).defaults.merge('name' => name, 'box' => "gusztavvargadr/#{name}-build")) do |machine|
    VagrantVirtualBoxProvider.configure(machine, machine.options.fetch('providers').fetch('virtualbox')) do |provider|
      provider.override.vm.box_url = "file://#{build_dir}/#{name}/virtualbox-vagrant/output/package/vagrant.box"
    end

    VagrantHyperVProvider.configure(machine, machine.options.fetch('providers').fetch('hyperv')) do |provider|
      provider.override.vm.box_url = "file://#{build_dir}/#{name}/hyperv-vagrant/output/package/vagrant.box"
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
