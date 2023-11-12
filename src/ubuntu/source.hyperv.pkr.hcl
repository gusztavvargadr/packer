packer {
  required_plugins {
    hyperv = {
      version = "~> 1.1"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}

variable "hyperv_switch" {
  type    = string
  default = "Default Switch"
}

locals {
  hyperv_source_options = {
    generation                       = 2
    configuration_version            = "9.0"
    enable_virtualization_extensions = false
    enable_dynamic_memory            = false
    enable_secure_boot               = false
    switch_name                      = var.hyperv_switch
    enable_mac_spoofing              = true
    disk_block_size                  = "1"
    guest_additions_mode             = "disable"
  }
}

locals {
  hyperv_iso_source_options = merge(local.core_source_options, local.hyperv_source_options, lookup(local.image_options, "hyperv", {}))
}

source "hyperv-iso" "core" {
  vm_name          = local.hyperv_iso_source_options.vm_name
  headless         = local.hyperv_iso_source_options.headless
  output_directory = local.hyperv_iso_source_options.output_directory

  cpus           = local.hyperv_iso_source_options.cpus
  memory         = local.hyperv_iso_source_options.memory
  disk_size      = local.hyperv_iso_source_options.disk_size
  iso_urls       = local.hyperv_iso_source_options.iso_urls
  iso_checksum   = local.hyperv_iso_source_options.iso_checksum
  http_directory = local.hyperv_iso_source_options.http_directory

  generation                       = local.hyperv_iso_source_options.generation
  configuration_version            = local.hyperv_iso_source_options.configuration_version
  enable_virtualization_extensions = local.hyperv_iso_source_options.enable_virtualization_extensions
  enable_dynamic_memory            = local.hyperv_iso_source_options.enable_dynamic_memory
  enable_secure_boot               = local.hyperv_iso_source_options.enable_secure_boot
  switch_name                      = local.hyperv_iso_source_options.switch_name
  enable_mac_spoofing              = local.hyperv_iso_source_options.enable_mac_spoofing
  disk_block_size                  = local.hyperv_iso_source_options.disk_block_size
  guest_additions_mode             = local.hyperv_iso_source_options.guest_additions_mode

  boot_command     = local.hyperv_iso_source_options.boot_command
  boot_wait        = local.hyperv_iso_source_options.boot_wait
  shutdown_command = local.hyperv_iso_source_options.shutdown_command
  shutdown_timeout = local.hyperv_iso_source_options.shutdown_timeout

  communicator = local.communicator.type
  ssh_username = local.communicator.username
  ssh_password = local.communicator.password
  ssh_timeout  = local.communicator.timeout
}

locals {
  hyperv_vmcx_source_options = merge(local.core_source_options, local.hyperv_source_options, lookup(local.image_options, "hyperv", {}))
}

source "hyperv-vmcx" "core" {
  vm_name          = local.hyperv_vmcx_source_options.vm_name
  headless         = local.hyperv_vmcx_source_options.headless
  output_directory = local.hyperv_vmcx_source_options.output_directory

  cpus                 = local.hyperv_vmcx_source_options.cpus
  memory               = local.hyperv_vmcx_source_options.memory
  clone_from_vmcx_path = "${local.import_directory}/${join("", fileset(local.import_directory, "**/*.vmcx"))}"

  generation                       = local.hyperv_vmcx_source_options.generation
  configuration_version            = local.hyperv_vmcx_source_options.configuration_version
  enable_virtualization_extensions = local.hyperv_vmcx_source_options.enable_virtualization_extensions
  enable_dynamic_memory            = local.hyperv_vmcx_source_options.enable_dynamic_memory
  enable_secure_boot               = local.hyperv_vmcx_source_options.enable_secure_boot
  switch_name                      = local.hyperv_vmcx_source_options.switch_name
  enable_mac_spoofing              = local.hyperv_vmcx_source_options.enable_mac_spoofing
  guest_additions_mode             = local.hyperv_iso_source_options.guest_additions_mode

  boot_command     = local.hyperv_vmcx_source_options.boot_command
  boot_wait        = local.hyperv_vmcx_source_options.boot_wait
  shutdown_command = local.hyperv_vmcx_source_options.shutdown_command
  shutdown_timeout = local.hyperv_vmcx_source_options.shutdown_timeout

  communicator = local.communicator.type
  ssh_username = local.communicator.username
  ssh_password = local.communicator.password
  ssh_timeout  = local.communicator.timeout
}
