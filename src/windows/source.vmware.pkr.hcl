packer {
  required_plugins {
    vmware = {
      version = "~> 1.0.11"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

locals {
  vmware_source_options = {
    version           = 20
    disk_type_id      = 0
    disk_adapter_type = "nvme"
    vmx_data = {
      firmware        = "efi"
      "vhv.enable"    = "FALSE"
      "sata1.present" = "TRUE"
    }
    vmx_remove_ethernet_interfaces = local.native_build ? false : true
  }
}

locals {
  vmware_iso_source_options = merge(local.source_options_build, local.vmware_source_options, lookup(local.image_options, "vmware", {}))
}

source "vmware-iso" "core" {
  vm_name          = local.vmware_iso_source_options.vm_name
  headless         = local.vmware_iso_source_options.headless
  output_directory = local.vmware_iso_source_options.output_directory

  cpus         = local.vmware_iso_source_options.cpus
  memory       = local.vmware_iso_source_options.memory
  disk_size    = local.vmware_iso_source_options.disk_size
  iso_urls     = local.vmware_iso_source_options.iso_urls
  iso_checksum = local.vmware_iso_source_options.iso_checksum
  cd_content   = local.vmware_iso_source_options.cd_content

  version                        = local.vmware_iso_source_options.version
  guest_os_type                  = local.vmware_iso_source_options.guest_os_type
  disk_type_id                   = local.vmware_iso_source_options.disk_type_id
  disk_adapter_type              = local.vmware_iso_source_options.disk_adapter_type
  vmx_data                       = local.vmware_iso_source_options.vmx_data
  vmx_remove_ethernet_interfaces = local.vmware_iso_source_options.vmx_remove_ethernet_interfaces

  boot_command     = local.vmware_iso_source_options.boot_command
  boot_wait        = local.vmware_iso_source_options.boot_wait
  shutdown_command = local.vmware_iso_source_options.shutdown_command
  shutdown_timeout = local.vmware_iso_source_options.shutdown_timeout

  communicator   = local.communicator.type
  ssh_username   = local.communicator.username
  ssh_password   = local.communicator.password
  ssh_timeout    = local.communicator.timeout
}

locals {
  vmware_vmx_source_options = merge(local.source_options_build, local.vmware_source_options, lookup(local.image_options, "vmware", {}))
}

source "vmware-vmx" "core" {
  vm_name          = local.vmware_vmx_source_options.vm_name
  headless         = local.vmware_vmx_source_options.headless
  output_directory = local.vmware_vmx_source_options.output_directory

  source_path = "${local.vmware_vmx_source_options.import_directory}/${join("", fileset(local.vmware_vmx_source_options.import_directory, "**/*.vmx"))}"

  vmx_remove_ethernet_interfaces = local.vmware_vmx_source_options.vmx_remove_ethernet_interfaces

  boot_command     = local.vmware_vmx_source_options.boot_command
  boot_wait        = local.vmware_vmx_source_options.boot_wait
  shutdown_command = local.vmware_vmx_source_options.shutdown_command
  shutdown_timeout = local.vmware_vmx_source_options.shutdown_timeout

  communicator   = local.communicator.type
  ssh_username   = local.communicator.username
  ssh_password   = local.communicator.password
  ssh_timeout    = local.communicator.timeout
}
