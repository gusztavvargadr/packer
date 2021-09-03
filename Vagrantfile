Vagrant.configure('2') do |config|
  vm_name = ENV['VAGRANT_VM_NAME'] || 'default'
  box_name = ENV['VAGRANT_BOX_NAME'] || ''
  box_url = ENV['VAGRANT_BOX_URL'] || ''

  config.vm.define vm_name

  config.vm.box = box_name
  config.vm.box_url = box_url

  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provider 'virtualbox' do |_|
  end

  config.vm.provider 'hyperv' do |p, override|
    p.enable_virtualization_extensions = true

    network_bridge = ENV['VAGRANT_HYPERV_NETWORK_BRIDGE'] || 'Default Switch'
    override.vm.network 'public_network', bridge: network_bridge
  end

  if vm_name.start_with?('w')
    config.vm.provision 'shell', inline: <<-EOF
      cmd /c ver
      chef-client --version
      Get-ComputerInfo
      choco list -li
    EOF
  else
    config.vm.provision 'shell', inline: <<-EOF
      uname -a
      lsb_release -a
      chef-client --version
      lshw
      apt list --installed
    EOF
  end
end
