packer {
  required_plugins {
    hyperv = {
      version = "~> 1.1.5"
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
    configuration_version            = "10.0"
    enable_virtualization_extensions = false
    enable_dynamic_memory            = false
    enable_secure_boot               = true
    secure_boot_template             = "MicrosoftWindows"
    switch_name                      = var.hyperv_switch
    enable_mac_spoofing              = true

    boot_wait = "-1s"
  }
}

locals {
  hyperv_iso_source_options = merge(local.source_options_build, local.hyperv_source_options, lookup(local.image_options, "hyperv", {}))
}

source "hyperv-iso" "core" {
  vm_name          = local.hyperv_iso_source_options.vm_name
  headless         = local.hyperv_iso_source_options.headless
  output_directory = local.hyperv_iso_source_options.output_directory

  cpus         = local.hyperv_iso_source_options.cpus
  memory       = local.hyperv_iso_source_options.memory
  disk_size    = local.hyperv_iso_source_options.disk_size
  iso_urls     = local.hyperv_iso_source_options.iso_urls
  iso_checksum = local.hyperv_iso_source_options.iso_checksum
  cd_content   = local.hyperv_iso_source_options.cd_content

  generation                       = local.hyperv_iso_source_options.generation
  configuration_version            = local.hyperv_iso_source_options.configuration_version
  enable_virtualization_extensions = local.hyperv_iso_source_options.enable_virtualization_extensions
  enable_dynamic_memory            = local.hyperv_iso_source_options.enable_dynamic_memory
  enable_secure_boot               = local.hyperv_iso_source_options.enable_secure_boot
  secure_boot_template             = local.hyperv_iso_source_options.secure_boot_template
  switch_name                      = local.hyperv_iso_source_options.switch_name
  enable_mac_spoofing              = local.hyperv_iso_source_options.enable_mac_spoofing

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
  hyperv_vmcx_source_options = merge(local.source_options_build, local.hyperv_source_options, lookup(local.image_options, "hyperv", {}))
}

source "hyperv-vmcx" "core" {
  vm_name          = local.hyperv_vmcx_source_options.vm_name
  headless         = local.hyperv_vmcx_source_options.headless
  output_directory = local.hyperv_vmcx_source_options.output_directory

  cpus                 = local.hyperv_vmcx_source_options.cpus
  memory               = local.hyperv_vmcx_source_options.memory
  clone_from_vmcx_path = "${local.hyperv_vmcx_source_options.import_directory}/${join("", fileset(local.hyperv_vmcx_source_options.import_directory, "image/**/*.vmcx"))}"

  generation                       = local.hyperv_vmcx_source_options.generation
  configuration_version            = local.hyperv_vmcx_source_options.configuration_version
  enable_virtualization_extensions = local.hyperv_vmcx_source_options.enable_virtualization_extensions
  enable_dynamic_memory            = local.hyperv_vmcx_source_options.enable_dynamic_memory
  enable_secure_boot               = local.hyperv_vmcx_source_options.enable_secure_boot
  secure_boot_template             = local.hyperv_vmcx_source_options.secure_boot_template
  switch_name                      = local.hyperv_vmcx_source_options.switch_name
  enable_mac_spoofing              = local.hyperv_vmcx_source_options.enable_mac_spoofing

  boot_command     = local.hyperv_vmcx_source_options.boot_command
  boot_wait        = local.hyperv_vmcx_source_options.boot_wait
  shutdown_command = local.hyperv_vmcx_source_options.shutdown_command
  shutdown_timeout = local.hyperv_vmcx_source_options.shutdown_timeout

  communicator = local.communicator.type
  ssh_username = local.communicator.username
  ssh_password = local.communicator.password
  ssh_timeout  = local.communicator.timeout
}
