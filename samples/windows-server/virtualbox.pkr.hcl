locals {
  guest_os_type        = "Windows2019_64"
  guest_additions_mode = "disable"
  firmware             = "efi"
  nested_virt          = true
  hard_drive_interface = "sata"
  gfx_controller       = "vboxsvga"
  gfx_vram_size        = 64

  post_shutdown_delay = "5s"
}

source "virtualbox-iso" "core" {
  vm_name          = local.vm_name
  headless         = local.headless
  output_directory = "${local.core_output_directory}/image"

  vboxmanage   = [["modifyvm", "{{ .Name }}", "--cpus", "${local.cpus}"], ["modifyvm", "{{ .Name }}", "--memory", "${local.memory}"]]
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

  guest_os_type        = local.guest_os_type
  guest_additions_mode = local.guest_additions_mode
  firmware             = local.firmware
  nested_virt          = local.nested_virt
  hard_drive_interface = local.hard_drive_interface
  gfx_controller       = local.gfx_controller
  gfx_vram_size        = local.gfx_vram_size
  post_shutdown_delay  = local.post_shutdown_delay
}

source "virtualbox-ovf" "vagrant" {
  vm_name          = local.vm_name
  headless         = local.headless
  output_directory = "${local.vagrant_output_directory}/image"

  vboxmanage   = [["modifyvm", "{{ .Name }}", "--cpus", "${local.cpus}"], ["modifyvm", "{{ .Name }}", "--memory", "${local.memory}"]]
  source_path = "${join("", fileset(path.root, "${local.core_output_directory}/image/*.ovf"))}"
  boot_wait   = local.boot_wait

  communicator   = local.communicator_type
  ssh_username   = local.communicator_username
  ssh_password   = local.communicator_password
  ssh_timeout    = local.communicator_timeout
  winrm_username = local.communicator_username
  winrm_password = local.communicator_password
  winrm_timeout  = local.communicator_timeout

  shutdown_command = local.shutdown_command
  shutdown_timeout = local.shutdown_timeout

  guest_additions_mode = local.guest_additions_mode
  post_shutdown_delay  = local.post_shutdown_delay
}
