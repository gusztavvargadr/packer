Vagrant.configure(2) do |config|
  config.vm.guest = :windows
  config.vm.boot_timeout = 600

  config.vm.communicator = 'winrm'
  config.winssh.shell = 'powershell'

  config.vm.provider 'vmware_desktop' do |vw|
    vw.cpus = 2
    vw.memory = 2048
  end

  config.vm.network :forwarded_port, guest: 3389, host: 53389, auto_correct: true
end
