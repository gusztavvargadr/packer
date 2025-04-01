packer {
  required_plugins {
    virtualbox = {
      version = "~> 1.1.0"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

locals {
  virtualbox_source_options = {
    guest_additions_mode = "disable"
    firmware             = "efi"
    nested_virt          = false
    hard_drive_interface = "sata"
    gfx_controller       = "vboxsvga"
    gfx_vram_size        = 64
    post_shutdown_delay  = "15s"
  }
}

locals {
  virtualbox_iso_source_options = merge(local.source_options_build, local.virtualbox_source_options, lookup(local.image_options, "virtualbox", {}))
}

source "virtualbox-iso" "core" {
  vm_name          = local.virtualbox_iso_source_options.vm_name
  headless         = local.virtualbox_iso_source_options.headless
  output_directory = local.virtualbox_iso_source_options.output_directory

  cpus         = local.virtualbox_iso_source_options.cpus
  memory       = local.virtualbox_iso_source_options.memory
  disk_size    = local.virtualbox_iso_source_options.disk_size
  iso_urls     = local.virtualbox_iso_source_options.iso_urls
  iso_checksum = local.virtualbox_iso_source_options.iso_checksum
  cd_content   = local.virtualbox_iso_source_options.cd_content

  guest_os_type        = local.virtualbox_iso_source_options.guest_os_type
  guest_additions_mode = local.virtualbox_iso_source_options.guest_additions_mode
  firmware             = local.virtualbox_iso_source_options.firmware
  nested_virt          = local.virtualbox_iso_source_options.nested_virt
  hard_drive_interface = local.virtualbox_iso_source_options.hard_drive_interface
  gfx_controller       = local.virtualbox_iso_source_options.gfx_controller
  gfx_vram_size        = local.virtualbox_iso_source_options.gfx_vram_size
  post_shutdown_delay  = local.virtualbox_iso_source_options.post_shutdown_delay

  boot_command     = local.virtualbox_iso_source_options.boot_command
  boot_wait        = local.virtualbox_iso_source_options.boot_wait
  shutdown_command = local.virtualbox_iso_source_options.shutdown_command
  shutdown_timeout = local.virtualbox_iso_source_options.shutdown_timeout

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

  source_path = "${local.virtualbox_ovf_source_options.import_directory}/${join("", fileset(local.virtualbox_ovf_source_options.import_directory, "**/*.ovf"))}"

  guest_additions_mode = local.virtualbox_ovf_source_options.guest_additions_mode
  post_shutdown_delay  = local.virtualbox_ovf_source_options.post_shutdown_delay

  boot_command     = local.virtualbox_ovf_source_options.boot_command
  boot_wait        = local.virtualbox_ovf_source_options.boot_wait
  shutdown_command = local.virtualbox_ovf_source_options.shutdown_command
  shutdown_timeout = local.virtualbox_ovf_source_options.shutdown_timeout

  communicator = local.communicator.type
  ssh_username = local.communicator.username
  ssh_password = local.communicator.password
  ssh_timeout  = local.communicator.timeout
}
