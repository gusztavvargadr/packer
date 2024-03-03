Vagrant.configure("2") do |config|
  hyperv_network_bridge = ENV["VAGRANT_HYPERV_NETWORK_BRIDGE"].to_s.strip || "Default Switch"
  config.vm.provider "hyperv" do |provider, override|
    provider.linked_clone = true

    override.vm.network "private_network", bridge: hyperv_network_bridge
  end

  config.vm.provider "virtualbox" do |provider, _override|
    provider.linked_clone = false
  end

  config.vm.provider "vmware_desktop" do |provider, _override|
    provider.linked_clone = true
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true
end

def config_vm_define(config, vm_name, box_name)
  box_author = ENV["VAGRANT_BOX_AUTHOR"] || "gusztavvargadr"
  box_author = box_author.to_s.strip
  box_url = ENV["VAGRANT_BOX_URL"]
  box_url = box_url.to_s.strip

  box = !box_url.empty? ? "#{box_author}-test/#{box_name}" : "#{box_author}/#{box_name}"

  config.vm.define vm_name, autostart: false do |config|
    config.vm.box = box
    config.vm.box_url = box_url unless box_url.empty?

    unless box_url.empty?
      config.trigger.after :destroy do |trigger|
        trigger.info = "Deleting box"
        trigger.run = { inline: "vagrant box remove #{box}"}
      end
    end
  end
end
