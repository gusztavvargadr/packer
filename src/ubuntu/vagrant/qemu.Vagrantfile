Vagrant.configure(2) do |config|
  config.vm.provider 'libvirt' do |provider, override|
    provider.cpus = ${options.cpus}
    provider.memory = ${options.memory}

%{ for port in compact(split(",", options.ports)) ~}
    override.vm.network :forwarded_port, guest: ${port}, host: ${50000 + port}, auto_correct: true
%{ endfor ~}

    provider.machine_type = "q35"

    ovmf_code_paths = [
      ENV["VAGRANT_LIBVIRT_OVMF_CODE"],
      "/usr/share/OVMF/OVMF_CODE_4M.fd",
      "/usr/share/OVMF/x64/OVMF_CODE.4m.fd",
    ].compact
    ovmf_code_path = ovmf_code_paths.find { |path| File.exist?(path) }
    
    if ovmf_code_path
      provider.qemuargs :value => "-drive"
      provider.qemuargs :value => "file=#{ovmf_code_path},if=pflash,unit=0,format=raw,readonly=on"
    else
      raise "OVMF firmware not found. Install ovmf/edk2-ovmf package or set VAGRANT_LIBVIRT_OVMF_CODE environment variable."
    end

    provider.cpu_mode = "host-passthrough"

    provider.graphics_type = "spice"
    provider.video_type = "virtio"

    provider.qemu_use_agent = true
  end
end
