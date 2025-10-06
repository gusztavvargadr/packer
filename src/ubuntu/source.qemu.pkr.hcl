packer {
  required_plugins {
    qemu = {
      version = "~> 1.1.3"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

locals {
  qemu_source_options = {
    # version           = 20
    # disk_type_id      = 0
    # disk_adapter_type = "nvme"
    # vmx_data = {
    #   firmware        = "efi"
    #   "vhv.enable"    = "FALSE"
    # }
    # vmx_remove_ethernet_interfaces = local.native_build ? false : true
  }
}

locals {
  qemu_iso_source_options = merge(local.source_options_build, local.qemu_source_options, lookup(local.image_options, "qemu", {}))
}

source "qemu" "iso" {
  vm_name          = local.qemu_iso_source_options.vm_name
  headless         = local.qemu_iso_source_options.headless
  output_directory = local.qemu_iso_source_options.output_directory

  cpus           = local.qemu_iso_source_options.cpus
  memory         = local.qemu_iso_source_options.memory
  disk_size      = local.qemu_iso_source_options.disk_size
  iso_urls       = local.qemu_iso_source_options.iso_urls
  iso_checksum   = local.qemu_iso_source_options.iso_checksum
  http_directory = local.qemu_iso_source_options.http_directory

  efi_boot = true
  accelerator = "kvm"
  format = "qcow2"

  boot_command     = local.qemu_iso_source_options.boot_command
  boot_wait        = local.qemu_iso_source_options.boot_wait
  shutdown_command = local.qemu_iso_source_options.shutdown_command
  shutdown_timeout = local.qemu_iso_source_options.shutdown_timeout

  communicator = local.communicator.type
  ssh_username = local.communicator.username
  ssh_password = local.communicator.password
  ssh_timeout  = local.communicator.timeout
}

locals {
  qemu_import_source_options = merge(local.source_options_build, local.qemu_source_options, lookup(local.image_options, "qemu", {}))
}

source "qemu" "import" {
  vm_name          = local.qemu_import_source_options.vm_name
  headless         = local.qemu_import_source_options.headless
  output_directory = local.qemu_import_source_options.output_directory

  iso_urls = [ "${local.qemu_import_source_options.import_directory}/${join("", fileset(local.qemu_import_source_options.import_directory, "**/*.qcow2"))}" ]
  iso_checksum = "6b085de9514691eeb5b932f83ae2a7fff42d9c15b7da5d597cf966d87621470b"
  disk_image = true
  skip_resize_disk = true

  cpus           = local.qemu_iso_source_options.cpus
  memory         = local.qemu_iso_source_options.memory
  disk_size      = local.qemu_iso_source_options.disk_size

  efi_boot = true
  accelerator = "kvm"
  format = "qcow2"

  boot_command     = local.qemu_import_source_options.boot_command
  boot_wait        = local.qemu_import_source_options.boot_wait
  shutdown_command = local.qemu_import_source_options.shutdown_command
  shutdown_timeout = local.qemu_import_source_options.shutdown_timeout

  communicator   = local.communicator.type
  ssh_username   = local.communicator.username
  ssh_password   = local.communicator.password
  ssh_timeout    = local.communicator.timeout
}
