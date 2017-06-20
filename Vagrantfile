options = {
  provider: {
    memory: 2048,
    cpus: 2,
    linked_clone: true,
    nested_virtualization: true,
  },
  network: {
    bridge: ENV['VAGRANT_NETWORK_BRIDGE'],
  },
}

Vagrant.configure('2') do |config|
  vm(config, 'w10e', options)

  vm(config, 'w16s', options)
  vm(config, 'w16s-iis', options)
  vm(config, 'w16s-sql14d', options)
  vm(config, 'w16s-vs17c', options)
  vm(config, 'w16s-vs17p', options)
end

def vm(config, name, options)
  config.vm.define name, autostart: false do |vm|
    vm.vm.box = "gusztavvargadr/#{name}"

    vm.vm.provider 'hyperv' do |hyperv, override|
      hyperv.memory = options[:provider][:memory]
      hyperv.cpus = options[:provider][:cpus]
      hyperv.differencing_disk = options[:provider][:linked_clone]
      hyperv.enable_virtualization_extensions = options[:provider][:nested_virtualization]

      override.vm.network 'public_network', bridge: options[:network][:bridge]
      override.vm.synced_folder '.', '/vagrant', smb_username: ENV['VAGRANT_SMB_USERNAME'], smb_password: ENV['VAGRANT_SMB_PASSWORD']
    end

    vm.vm.provider 'virtualbox' do |virtualbox|
      virtualbox.memory = options[:provider][:memory]
      virtualbox.cpus = options[:provider][:cpus]
      virtualbox.linked_clone = options[:provider][:linked_clone]
    end
  end
end
