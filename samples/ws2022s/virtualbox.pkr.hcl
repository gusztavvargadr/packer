locals {
  guest_os_type        = "Windows2019_64"
  guest_additions_mode = "disable"
  firmware             = "efi"
  nested_virt          = true
  gfx_controller       = "vboxsvga"
  gfx_vram_size        = 64
  hard_drive_interface = "sata"
  post_shutdown_delay  = "5s"
}

source "virtualbox-iso" "default" {
  vm_name = local.vm_name
  cpus    = local.cpus
  memory  = local.memory

  boot_wait              = local.boot_wait
  boot_command           = local.boot_command
  boot_keygroup_interval = local.boot_keygroup_interval
  headless               = local.headless

  communicator   = local.communicator_type
  winrm_username = local.communicator_username
  winrm_password = local.communicator_password
  winrm_timeout  = local.communicator_timeout

  shutdown_command = local.shutdown_command
  shutdown_timeout = local.shutdown_timeout

  iso_urls     = local.iso_urls
  iso_checksum = local.iso_checksum
  disk_size    = local.disk_size
  cd_files     = local.cd_files

  guest_os_type        = local.guest_os_type
  guest_additions_mode = local.guest_additions_mode
  firmware             = local.firmware
  nested_virt          = local.nested_virt
  gfx_controller       = local.gfx_controller
  gfx_vram_size        = local.gfx_vram_size
  hard_drive_interface = local.hard_drive_interface
  post_shutdown_delay  = local.post_shutdown_delay
}
