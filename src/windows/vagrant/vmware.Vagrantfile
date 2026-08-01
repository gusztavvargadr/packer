Vagrant.configure(2) do |config|
  config.vm.guest = :windows
  config.vm.communicator = 'winrm'
  config.winssh.shell = 'powershell'

  config.vm.provider 'vmware_desktop' do |provider, override|
    provider.cpus = ${options.cpus}
    provider.memory = ${options.memory}

%{ for port in compact(split(",", options.ports)) ~}
    override.vm.network :forwarded_port, guest: ${port}, host: ${50000 + port}, auto_correct: true
%{ endfor ~}
%{ for network_adapter_type in compact([lookup(provider_options, "network_adapter_type", "")]) ~}
    provider.vmx["ethernet0.pcislotnumber"] = "${lookup(provider_options, "network_adapter_pcislotnumber", "160")}"
    provider.vmx["ethernet0.virtualDev"] = "${network_adapter_type}"
%{ endfor ~}
  end
end
