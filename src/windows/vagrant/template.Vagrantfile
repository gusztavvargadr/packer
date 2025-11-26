Vagrant.configure(2) do |config|
  config.vm.guest = :windows
  config.vm.communicator = 'winrm'
  config.winssh.shell = 'powershell'

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

  config.vm.provider 'hyperv' do |provider|
    provider.cpus = ${options.cpus}
    provider.memory = ${options.memory}
  end

  config.vm.provider 'libvirt' do |provider, override|
    provider.cpus = ${options.cpus}
    provider.memory = ${options.memory}

%{ for port in compact(split(",", options.ports)) ~}
    override.vm.network :forwarded_port, guest: ${port}, host: ${50000 + port}, auto_correct: true
%{ endfor ~}

    provider.machine_type = "q35"

    provider.qemuargs :value => "-drive"
    provider.qemuargs :value => "file=/usr/share/OVMF/OVMF_CODE_4M.fd,if=pflash,unit=0,format=raw,readonly=on"

    provider.cpu_mode = "host-passthrough"

    provider.disk_bus = "ide"
    provider.nic_model_type = "e1000e"

    provider.graphics_type = "spice"
    provider.video_type = "qxl"

    provider.qemu_use_agent = true
  end
end
