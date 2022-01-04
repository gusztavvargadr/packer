locals {
  generation                       = 2
  configuration_version            = "9.0"
  enable_virtualization_extensions = true
  enable_dynamic_memory            = false
  enable_secure_boot               = true
  secure_boot_template             = "MicrosoftWindows"
  switch_name                      = "Default Switch"
  enable_mac_spoofing              = true
}

source "hyperv-iso" "default" {
  vm_name  = local.vm_name
  cpus     = local.cpus
  memory   = local.memory
  headless = local.headless

  disk_size    = local.disk_size
  iso_urls     = local.iso_urls
  iso_checksum = local.iso_checksum
  cd_content   = local.cd_content

  boot_wait              = local.boot_wait
  boot_command           = local.boot_command
  boot_keygroup_interval = local.boot_keygroup_interval

  communicator   = local.communicator_type
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
