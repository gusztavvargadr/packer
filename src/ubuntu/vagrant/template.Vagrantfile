Vagrant.configure(2) do |config|
  config.vm.provider 'virtualbox' do |provider, override|
    provider.cpus = ${options.cpus}
    provider.memory = ${options.memory}

%{ for port in compact(split(",", options.ports)) ~}
    override.vm.network :forwarded_port, guest: ${port}, host: ${50000 + port}, auto_correct: true
%{ endfor ~}
  end

  config.vm.provider 'vmware_desktop' do |provider, override|
    provider.cpus = ${options.cpus}
    provider.memory = ${options.memory}

%{ for port in compact(split(",", options.ports)) ~}
    override.vm.network :forwarded_port, guest: ${port}, host: ${50000 + port}, auto_correct: true
%{ endfor ~}
  end

  config.vm.provider 'hyperv' do |provider, override|
    provider.cpus = ${options.cpus}
    provider.memory = ${options.memory}
  end

  config.vm.provider 'libvirt' do |provider, override|
    provider.machine_type = "q35"
    provider.loader = '/usr/share/OVMF/OVMF_CODE.fd'

    provider.cpus = ${options.cpus}
    provider.memory = ${options.memory}

%{ for port in compact(split(",", options.ports)) ~}
    override.vm.network :forwarded_port, guest: ${port}, host: ${50000 + port}, auto_correct: true
%{ endfor ~}
  end
end
