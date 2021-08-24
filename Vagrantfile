Vagrant.configure('2') do |config|
  config.vm.box = ENV['VAGRANT_BOX'] || ''

  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provider 'virtualbox' do |_|
  end

  config.vm.provider 'hyperv' do |p, override|
    p.linked_clone = true
    p.enable_virtualization_extensions = true

    network_bridge = ENV['VAGRANT_HYPERV_NETWORK_BRIDGE'] || 'Default Switch'
    override.vm.network 'public_network', bridge: network_bridge
  end

  if config.vm.box.start_with?('w')
    config.vm.provision 'shell', inline: <<-EOF
      cmd /c ver
      chef-client --version
      Get-ComputerInfo
      choco list -li
    EOF
  else
    config.vm.provision 'shell', inline: <<-EOF
      uname -a
      chef-client --version
      lshw
      apt list --installed
    EOF
  end
end
