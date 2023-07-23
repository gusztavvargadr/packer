variables {
  hyperv_switch_name = "Default Switch"
}

locals {
  hyperv_boot_wait = "-1s"

  hyperv_generation                       = 2
  hyperv_configuration_version            = "9.0"
  hyperv_enable_virtualization_extensions = false
  hyperv_enable_dynamic_memory            = false
  hyperv_enable_secure_boot               = true
  hyperv_secure_boot_template             = "MicrosoftWindows"
  hyperv_switch_name                      = var.hyperv_switch_name
  hyperv_enable_mac_spoofing              = true
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
  boot_wait    = local.hyperv_boot_wait
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

  generation                       = local.hyperv_generation
  configuration_version            = local.hyperv_configuration_version
  enable_virtualization_extensions = local.hyperv_enable_virtualization_extensions
  enable_dynamic_memory            = local.hyperv_enable_dynamic_memory
  enable_secure_boot               = local.hyperv_enable_secure_boot
  secure_boot_template             = local.hyperv_secure_boot_template
  switch_name                      = local.hyperv_switch_name
  enable_mac_spoofing              = local.hyperv_enable_mac_spoofing
}

source "hyperv-vmcx" "vagrant" {
  vm_name          = local.vm_name
  headless         = local.headless
  output_directory = "${local.vagrant_output_directory}/image"

  cpus                 = local.cpus
  memory               = local.memory
  clone_from_vmcx_path = "${join("", fileset(path.root, "${local.core_output_directory}/**/*.vmcx"))}"
  boot_wait            = local.hyperv_boot_wait

  communicator   = local.communicator_type
  ssh_username   = local.communicator_username
  ssh_password   = local.communicator_password
  ssh_timeout    = local.communicator_timeout
  winrm_username = local.communicator_username
  winrm_password = local.communicator_password
  winrm_timeout  = local.communicator_timeout

  shutdown_command = local.shutdown_command
  shutdown_timeout = local.shutdown_timeout

  generation                       = local.hyperv_generation
  configuration_version            = local.hyperv_configuration_version
  enable_virtualization_extensions = local.hyperv_enable_virtualization_extensions
  enable_dynamic_memory            = local.hyperv_enable_dynamic_memory
  enable_secure_boot               = local.hyperv_enable_secure_boot
  secure_boot_template             = local.hyperv_secure_boot_template
  switch_name                      = local.hyperv_switch_name
  enable_mac_spoofing              = local.hyperv_enable_mac_spoofing
}
