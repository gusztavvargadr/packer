box_url = ENV["VAGRANT_BOX_URL"]
hyperv_network_bridge = ENV["VAGRANT_HYPERV_NETWORK_BRIDGE"] || "Default Switch"

Vagrant.configure("2") do |config|
  unless box_url.to_s.empty?
    config.vm.define "local", primary: true do |config|
      config.vm.box = "gusztavvargadr/local"
      config.vm.box_url = box_url
    end
  end

  config.vm.provider "virtualbox" do |provider, _override|
    provider.linked_clone = false
  end

  config.vm.provider "vmware_desktop" do |provider, _override|
    provider.linked_clone = true
  end

  config.vm.provider "hyperv" do |provider, override|
    provider.linked_clone = true

    override.vm.network "private_network", bridge: hyperv_network_bridge
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true
end
