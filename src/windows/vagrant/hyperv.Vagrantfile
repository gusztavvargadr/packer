Vagrant.configure(2) do |config|
  config.vm.guest = :windows
  config.vm.communicator = 'winrm'
  config.winssh.shell = 'powershell'

  config.vm.provider 'hyperv' do |provider|
    provider.cpus = ${options.cpus}
    provider.memory = ${options.memory}
  end
end
