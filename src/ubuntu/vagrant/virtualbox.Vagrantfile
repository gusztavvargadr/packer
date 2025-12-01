Vagrant.configure(2) do |config|
  config.vm.provider 'virtualbox' do |provider, override|
    provider.cpus = ${options.cpus}
    provider.memory = ${options.memory}

%{ for port in compact(split(",", options.ports)) ~}
    override.vm.network :forwarded_port, guest: ${port}, host: ${50000 + port}, auto_correct: true
%{ endfor ~}
  end
end
