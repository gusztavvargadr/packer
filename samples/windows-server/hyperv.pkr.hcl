variables {
  hyperv_switch_name = "Default Switch"
}

locals {
  generation                       = 2
  configuration_version            = "9.0"
  enable_virtualization_extensions = true
  enable_dynamic_memory            = false
  enable_secure_boot               = true
  secure_boot_template             = "MicrosoftWindows"
  switch_name                      = var.hyperv_switch_name
  enable_mac_spoofing              = true
}

source "hyperv-iso" "core" {
  vm_name          = local.vm_name
  headless         = local.headless
  output_directory = "${local.core_output_directory}/image"

  cpus         = local.cpus
  memory       = local.memory
  disk_size    = local.disk_size
  iso_urls     = local.iso_urls
  iso_checksum = local.iso_checksum
  cd_content   = local.cd_content
  boot_wait    = local.boot_wait // -1
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

  generation                       = local.generation
  configuration_version            = local.configuration_version
  enable_virtualization_extensions = local.enable_virtualization_extensions
  enable_dynamic_memory            = local.enable_dynamic_memory
  enable_secure_boot               = local.enable_secure_boot
  secure_boot_template             = local.secure_boot_template
  switch_name                      = local.switch_name
  enable_mac_spoofing              = local.enable_mac_spoofing
}

source "hyperv-vmcx" "vagrant" {
  vm_name          = local.vm_name
  headless         = local.headless
  output_directory = "${local.vagrant_output_directory}/image"

  cpus                 = local.cpus
  memory               = local.memory
  clone_from_vmcx_path = "${join("", fileset(path.root, "${local.core_output_directory}/image/*.vmcx"))}"
  boot_wait            = local.boot_wait // -1

  communicator   = local.communicator_type
  ssh_username   = local.communicator_username
  ssh_password   = local.communicator_password
  ssh_timeout    = local.communicator_timeout
  winrm_username = local.communicator_username
  winrm_password = local.communicator_password
  winrm_timeout  = local.communicator_timeout

  shutdown_command = local.shutdown_command
  shutdown_timeout = local.shutdown_timeout

  generation                       = local.generation
  configuration_version            = local.configuration_version
  enable_virtualization_extensions = local.enable_virtualization_extensions
  enable_dynamic_memory            = local.enable_dynamic_memory
  enable_secure_boot               = local.enable_secure_boot
  secure_boot_template             = local.secure_boot_template
  switch_name                      = local.switch_name
  enable_mac_spoofing              = local.enable_mac_spoofing
}
