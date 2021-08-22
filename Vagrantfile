def directory
  File.dirname(__FILE__)
end

def build_dir
  "#{directory}/build"
end

def version
  '2108'
end

Vagrant.configure('2') do |config|
  config.vm.provider 'virtualbox' do |_|
  end

  config.vm.provider 'hyperv' do |p, override|
    p.linked_clone = true
    p.enable_virtualization_extensions = true

    network_bridge = ENV['VAGRANT_HYPERV_NETWORK_BRIDGE'] || 'Default Switch'
    override.vm.network 'public_network', bridge: network_bridge
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true

  names = [
    'ws2016s',
    'ws2019s',
    'ws2016sc',
    'ws2019sc',
    'wsips',
    'wsipsc',

    'w101809eltsc',
    'w102009e',
    'w102101e',
    'w10ipe',

    'u1604s',

    'u1604d',

    'ws2019s-de',
    'ws2019sc-de',

    'u1604s-dc',
    'u1604d-dc',
    'w102101e-dc',

    'ws2019s-iis',
    'ws2019sc-iis',

    'ws2019s-sql17d',
    'ws2019s-sql19d',

    # 'w102101e-dc-vs17c',
    # 'w102101e-dc-vs17p',
    # 'w102101e-dc-vs19c',
    # 'w102101e-dc-vs19p',
  ]
  names.each do |name|
    config.vm.define name, autostart: false do |machine|
      machine.vm.box = "gusztavvargadr/#{name}-build"

      machine.vm.provider 'virtualbox' do |_, override|
        override.vm.box_url = "file:///#{build_dir}/#{name}/virtualbox-vagrant/output/package/vagrant.box"
      end

      machine.vm.provider 'hyperv' do |_, override|
        override.vm.box_url = "file:///#{build_dir}/#{name}/hyperv-vagrant/output/package/vagrant.box"
      end
    end
  end
end

# class VagrantWindowsMachine < VagrantMachine
#       'shell' => {
#         'inline' => <<-EOF
#           cmd /c ver
#           Get-ComputerInfo
#           choco list -li
#         EOF
#       },
#       # 'chef_policyfile' => {
#       #   'paths' => [
#       #     'Policyfile.rb',
#       #   ],
#       # },
# end

# class VagrantLinuxMachine < VagrantMachine
#       'shell' => {
#         'inline' => <<-EOF
#           uname -a
#           lshw
#           apt list --installed
#         EOF
#       },
#       # 'chef_policyfile' => {
#       #   'paths' => [
#       #     'Policyfile.rb',
#       #   ],
#       # },
# end
