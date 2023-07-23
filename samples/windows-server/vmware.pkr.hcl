locals {
  vmware_version           = 16
  vmware_guest_os_type     = "windows2019srv-64"
  vmware_disk_type_id      = 0
  vmware_disk_adapter_type = "nvme"
  vmware_vmx_data = {
    firmware     = "efi"
    "vhv.enable" = "FALSE"
  }

  vmware_vmx_remove_ethernet_interfaces = true
}

source "vmware-iso" "core" {
  vm_name          = local.vm_name
  headless         = local.headless
  output_directory = "${local.core_output_directory}/image"

  cpus           = local.cpus
  memory         = local.memory
  disk_size      = local.disk_size
  iso_urls       = local.iso_urls
  iso_checksum   = local.iso_checksum
  floppy_content = local.cd_content
  boot_wait      = local.boot_wait
  boot_command   = local.boot_command

  communicator   = local.communicator_type
  ssh_username   = local.communicator_username
  ssh_password   = local.communicator_password
  ssh_timeout    = local.communicator_timeout
  winrm_username = local.communicator_username
  winrm_password = local.communicator_password
  winrm_timeout  = local.communicator_timeout

  shutdown_command = local.shutdown_command
  shutdown_timeout = local.shutdown_timeout

  version           = local.vmware_version
  guest_os_type     = local.vmware_guest_os_type
  disk_type_id      = local.vmware_disk_type_id
  disk_adapter_type = local.vmware_disk_adapter_type
  vmx_data          = local.vmware_vmx_data
}

source "vmware-vmx" "vagrant" {
  vm_name          = local.vm_name
  headless         = local.headless
  output_directory = "${local.vagrant_output_directory}/image"

  source_path = "${join("", fileset(path.root, "${local.core_output_directory}/**/*.vmx"))}"
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

  vmx_remove_ethernet_interfaces = local.vmware_vmx_remove_ethernet_interfaces
}
