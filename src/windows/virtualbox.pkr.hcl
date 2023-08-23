packer {
  required_plugins {
    virtualbox = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

locals {
  virtualbox_guest_os_type        = local.options.virtualbox_guest_os_type
  virtualbox_guest_additions_mode = "disable"
  virtualbox_firmware             = "efi"
  virtualbox_nested_virt          = false
  virtualbox_hard_drive_interface = "sata"
  virtualbox_gfx_controller       = "vboxsvga"
  virtualbox_gfx_vram_size        = 64
  virtualbox_post_shutdown_delay  = "5s"
}

source "virtualbox-iso" "core" {
  vm_name          = local.vm_name
  headless         = local.headless
  output_directory = "${local.core_output_directory}/image"

  cpus         = local.cpus
  memory       = local.memory
  disk_size    = local.disk_size
  iso_urls     = local.iso_urls
  iso_checksum = local.iso_checksum
  cd_content   = local.cd_content
  boot_wait    = local.boot_wait
  boot_command = local.boot_command

  communicator   = local.communicator_type
  ssh_username   = local.communicator_username
  ssh_password   = local.communicator_password
  ssh_timeout    = local.communicator_timeout
  winrm_username = local.communicator_username
  winrm_password = local.communicator_password
  winrm_timeout  = local.communicator_timeout

  shutdown_command = local.shutdown_command
  shutdown_timeout = local.shutdown_timeout

  guest_os_type        = local.virtualbox_guest_os_type
  guest_additions_mode = local.virtualbox_guest_additions_mode
  firmware             = local.virtualbox_firmware
  nested_virt          = local.virtualbox_nested_virt
  hard_drive_interface = local.virtualbox_hard_drive_interface
  gfx_controller       = local.virtualbox_gfx_controller
  gfx_vram_size        = local.virtualbox_gfx_vram_size
  post_shutdown_delay  = local.virtualbox_post_shutdown_delay
}

source "virtualbox-ovf" "core" {
  vm_name          = local.vm_name
  headless         = local.headless
  output_directory = "${local.vagrant_output_directory}/image"

  source_path = "${local.core_output_directory}/${join("", fileset(local.core_output_directory, "**/*.ovf"))}"
  boot_wait   = local.boot_wait

  communicator   = local.communicator_type
  ssh_username   = local.communicator_username
  ssh_password   = local.communicator_password
  ssh_timeout    = local.communicator_timeout
  winrm_username = local.communicator_username
  winrm_password = local.communicator_password
  winrm_timeout  = local.communicator_timeout

  shutdown_command = local.vagrant_shutdown_command
  shutdown_timeout = local.shutdown_timeout

  guest_additions_mode = local.virtualbox_guest_additions_mode
  post_shutdown_delay  = local.virtualbox_post_shutdown_delay
}
