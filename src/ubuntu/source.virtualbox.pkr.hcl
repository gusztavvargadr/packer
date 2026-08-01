packer {
  required_plugins {
    virtualbox = {
      version = "~> 1.1.4"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

locals {
  virtualbox_source_options = {
    audio_controller     = "ac97"
    chipset              = "piix3"
    firmware             = "efi"
    gfx_controller       = "vmsvga"
    gfx_vram_size        = 128
    guest_additions_mode = "disable"
    hard_drive_interface = "sata"
    iso_interface        = "ide"
    keyboard             = "ps2"
    mouse                = "ps2"
    nested_virt          = false
    nic_type             = "82540EM"
    post_shutdown_delay  = "15s"
    usb                  = false
    usb_controller       = "ehci"
  }
}

locals {
  virtualbox_iso_source_options = merge(local.source_options_build, local.virtualbox_source_options, lookup(local.image_options, "virtualbox", {}))
  virtualbox_iso_arm64          = local.image_architecture == "arm64"
}

source "virtualbox-iso" "core" {
  vm_name          = local.virtualbox_iso_source_options.vm_name
  headless         = local.virtualbox_iso_source_options.headless
  output_directory = local.virtualbox_iso_source_options.output_directory

  cpus           = local.virtualbox_iso_source_options.cpus
  memory         = local.virtualbox_iso_source_options.memory
  disk_size      = local.virtualbox_iso_source_options.disk_size
  iso_urls       = local.virtualbox_iso_source_options.iso_urls
  iso_checksum   = local.virtualbox_iso_source_options.iso_checksum
  http_directory = local.virtualbox_iso_source_options.http_directory

  audio_controller     = local.virtualbox_iso_source_options.audio_controller
  chipset              = local.virtualbox_iso_source_options.chipset
  firmware             = local.virtualbox_iso_source_options.firmware
  gfx_controller       = local.virtualbox_iso_source_options.gfx_controller
  gfx_vram_size        = local.virtualbox_iso_source_options.gfx_vram_size
  guest_additions_mode = local.virtualbox_iso_source_options.guest_additions_mode
  guest_os_type        = local.virtualbox_iso_source_options.guest_os_type
  hard_drive_interface = local.virtualbox_iso_source_options.hard_drive_interface
  iso_interface        = local.virtualbox_iso_source_options.iso_interface
  keyboard             = local.virtualbox_iso_source_options.keyboard
  mouse                = local.virtualbox_iso_source_options.mouse
  nested_virt          = local.virtualbox_iso_source_options.nested_virt
  nic_type             = local.virtualbox_iso_source_options.nic_type
  usb                  = local.virtualbox_iso_source_options.usb
  usb_controller       = local.virtualbox_iso_source_options.usb_controller

  # The plugin creates an unused IDE controller which VirtualBox cannot assign on ARM64.
  vboxmanage = local.virtualbox_iso_arm64 ? [
    ["storagectl", "{{.Name}}", "--name", "IDE", "--remove"]
  ] : []

  boot_command           = local.virtualbox_iso_source_options.boot_command
  boot_keygroup_interval = local.virtualbox_iso_arm64 ? "1s" : "100ms"
  boot_wait              = local.virtualbox_iso_arm64 ? "10s" : local.virtualbox_iso_source_options.boot_wait
  shutdown_command       = local.virtualbox_iso_source_options.shutdown_command
  shutdown_timeout       = local.virtualbox_iso_source_options.shutdown_timeout

  communicator = local.communicator.type
  ssh_username = local.communicator.username
  ssh_password = local.communicator.password
  ssh_timeout  = local.communicator.timeout
}

locals {
  virtualbox_ovf_source_options = merge(local.source_options_build, local.virtualbox_source_options, lookup(local.image_options, "virtualbox", {}))
}

source "virtualbox-ovf" "core" {
  vm_name          = local.virtualbox_ovf_source_options.vm_name
  headless         = local.virtualbox_ovf_source_options.headless
  output_directory = local.virtualbox_ovf_source_options.output_directory

  source_path = "${local.virtualbox_ovf_source_options.import_directory}/${join("", fileset(local.virtualbox_ovf_source_options.import_directory, "image/*.ovf"))}"

  guest_additions_mode = local.virtualbox_ovf_source_options.guest_additions_mode

  boot_command     = local.virtualbox_ovf_source_options.boot_command
  boot_wait        = local.virtualbox_ovf_source_options.boot_wait
  shutdown_command = local.virtualbox_ovf_source_options.shutdown_command
  shutdown_timeout = local.virtualbox_ovf_source_options.shutdown_timeout

  communicator = local.communicator.type
  ssh_username = local.communicator.username
  ssh_password = local.communicator.password
  ssh_timeout  = local.communicator.timeout
}
