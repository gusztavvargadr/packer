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
    machine_type       = "q35"
    accelerator        = "kvm"
    cpu_model          = "host"
    format             = "qcow2"
    efi_firmware_code  = "/usr/share/OVMF/OVMF_CODE_4M.fd"
    efi_drop_efivars   = true
    disk_interface     = "ide"
    disk_detect_zeroes = "unmap"
    net_device         = "e1000e"
    vga                = "qxl"
    qemuargs = [
      ["-device", "qemu-xhci"],
      ["-device", "virtio-tablet"],
    ]
  }
}

locals {
  qemu_iso_source_options = merge(local.source_options_build, local.qemu_source_options, lookup(local.image_options, "qemu", {}))
}

source "qemu" "iso" {
  vm_name          = local.qemu_iso_source_options.vm_name
  headless         = local.qemu_iso_source_options.headless
  output_directory = local.qemu_iso_source_options.output_directory

  cpus         = local.qemu_iso_source_options.cpus
  memory       = local.qemu_iso_source_options.memory
  disk_size    = local.qemu_iso_source_options.disk_size
  iso_urls     = local.qemu_iso_source_options.iso_urls
  iso_checksum = local.qemu_iso_source_options.iso_checksum
  cd_content   = local.qemu_iso_source_options.cd_content

  machine_type       = local.qemu_iso_source_options.machine_type
  accelerator        = local.qemu_iso_source_options.accelerator
  cpu_model          = local.qemu_iso_source_options.cpu_model
  format             = local.qemu_iso_source_options.format
  efi_firmware_code  = local.qemu_iso_source_options.efi_firmware_code
  efi_drop_efivars   = local.qemu_iso_source_options.efi_drop_efivars
  disk_interface     = local.qemu_iso_source_options.disk_interface
  disk_detect_zeroes = local.qemu_iso_source_options.disk_detect_zeroes
  net_device         = local.qemu_iso_source_options.net_device
  vga                = local.qemu_iso_source_options.vga
  qemuargs           = local.qemu_iso_source_options.qemuargs

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
  qemu_manifest_path         = "${local.qemu_import_source_options.import_directory}/manifest.json"
  qemu_checksum_path         = "${local.qemu_import_source_options.import_directory}/checksum.sha256"
}

source "qemu" "import" {
  vm_name          = local.qemu_import_source_options.vm_name
  headless         = local.qemu_import_source_options.headless
  output_directory = local.qemu_import_source_options.output_directory

  cpus             = local.qemu_import_source_options.cpus
  memory           = local.qemu_import_source_options.memory
  disk_size        = local.qemu_import_source_options.disk_size
  iso_urls         = [fileexists(local.qemu_manifest_path) ? "${local.qemu_import_source_options.import_directory}/${join("", fileset(local.qemu_import_source_options.import_directory, "image/*[^.fd]"))}" : ""]
  iso_checksum     = fileexists(local.qemu_checksum_path) ? try(trimspace(split("\t", split("\n", file(local.qemu_checksum_path))[0])[0]), "") : ""
  disk_image       = true
  skip_resize_disk = true

  machine_type       = local.qemu_import_source_options.machine_type
  accelerator        = local.qemu_import_source_options.accelerator
  cpu_model          = local.qemu_import_source_options.cpu_model
  format             = local.qemu_import_source_options.format
  efi_firmware_code  = local.qemu_import_source_options.efi_firmware_code
  efi_drop_efivars   = local.qemu_import_source_options.efi_drop_efivars
  disk_interface     = local.qemu_import_source_options.disk_interface
  disk_detect_zeroes = local.qemu_import_source_options.disk_detect_zeroes
  net_device         = local.qemu_import_source_options.net_device
  vga                = local.qemu_import_source_options.vga
  qemuargs           = local.qemu_import_source_options.qemuargs

  boot_command     = local.qemu_import_source_options.boot_command
  boot_wait        = local.qemu_import_source_options.boot_wait
  shutdown_command = local.qemu_import_source_options.shutdown_command
  shutdown_timeout = local.qemu_import_source_options.shutdown_timeout

  communicator = local.communicator.type
  ssh_username = local.communicator.username
  ssh_password = local.communicator.password
  ssh_timeout  = local.communicator.timeout
}
