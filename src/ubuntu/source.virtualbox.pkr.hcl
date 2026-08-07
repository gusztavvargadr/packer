packer {
  required_plugins {
    virtualbox = {
      version = "= 1.1.5"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "virtualbox_native_producer_prototype" {
  type    = bool
  default = false
}

variable "virtualbox_vagrant_sparse_prototype" {
  type    = bool
  default = false
}

locals {
  virtualbox_native_producer_prototype_input = var.virtualbox_native_producer_prototype
  virtualbox_vagrant_sparse_prototype_input  = var.virtualbox_vagrant_sparse_prototype
  virtualbox_registered_producer_input       = local.virtualbox_native_producer_prototype_input || local.virtualbox_vagrant_sparse_prototype_input
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
  virtualbox_image_options = lookup(local.image_options, "virtualbox", {})

  virtualbox_boot_command_key_buffer = lookup(local.virtualbox_image_options, "boot_command_key_buffer", "false") == "true" ? join("", [for index in range(32) : " "]) : ""
  virtualbox_remove_ide_controller   = lookup(local.virtualbox_image_options, "remove_ide_controller", "false") == "true"

  virtualbox_iso_source_options = merge(local.source_options_build, local.virtualbox_source_options, local.virtualbox_image_options)
  virtualbox_iso_boot_command = [
    for index, command in local.virtualbox_iso_source_options.boot_command : index == 0 ? command : "${local.virtualbox_boot_command_key_buffer}${command}"
  ]
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
  keep_registered      = local.virtualbox_native_producer_prototype_input
  mouse                = local.virtualbox_iso_source_options.mouse
  nested_virt          = local.virtualbox_iso_source_options.nested_virt
  nic_type             = local.virtualbox_iso_source_options.nic_type
  usb                  = local.virtualbox_iso_source_options.usb
  usb_controller       = local.virtualbox_iso_source_options.usb_controller

  # Remove the plugin-created IDE controller when the selected image cannot assign it.
  vboxmanage = local.virtualbox_remove_ide_controller ? [
    ["storagectl", "{{.Name}}", "--name", "IDE", "--remove"]
  ] : []

  boot_command           = local.virtualbox_iso_boot_command
  boot_keygroup_interval = lookup(local.virtualbox_image_options, "boot_keygroup_interval", "100ms")
  boot_wait              = local.virtualbox_iso_source_options.boot_wait
  shutdown_command       = local.virtualbox_iso_source_options.shutdown_command
  shutdown_timeout       = local.virtualbox_iso_source_options.shutdown_timeout
  skip_export            = local.virtualbox_native_producer_prototype_input

  communicator = local.communicator.type
  ssh_username = local.communicator.username
  ssh_password = local.communicator.password
  ssh_timeout  = local.communicator.timeout
}

locals {
  virtualbox_ovf_source_options = merge(local.source_options_build, local.virtualbox_source_options, local.virtualbox_image_options)
}

source "virtualbox-ovf" "core" {
  vm_name          = local.virtualbox_ovf_source_options.vm_name
  headless         = local.virtualbox_ovf_source_options.headless
  output_directory = local.virtualbox_ovf_source_options.output_directory

  source_path     = "${local.virtualbox_ovf_source_options.import_directory}/${join("", fileset(local.virtualbox_ovf_source_options.import_directory, "image/*.ovf"))}"
  import_flags    = local.virtualbox_registered_producer_input ? ["--basefolder", local.virtualbox_ovf_source_options.output_directory] : []
  keep_registered = local.virtualbox_registered_producer_input
  skip_export     = local.virtualbox_registered_producer_input

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
