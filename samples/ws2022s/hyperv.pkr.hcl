locals {
  vm_name                          = "${var.author}-${var.name}-${var.version}-${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
  generation                       = 2
  configuration_version            = "9.0"
  cpus                             = 2
  enable_virtualization_extensions = true
  memory                           = 4096
  enable_dynamic_memory            = false
  switch_name                      = "Default Switch"
  enable_mac_spoofing              = true
  enable_secure_boot               = true
  secure_boot_template             = "MicrosoftWindows"
  boot_wait                        = "1s"
  boot_command                     = ["<enter><wait>", "<enter><wait>", "<enter><wait>"]
  boot_keygroup_interval           = "1s"
  headless                         = true

  communicator_type     = "winrm"
  communicator_username = "Administrator"
  communicator_password = "Packer42-"
  communicator_timeout  = "30m"

  shutdown_command = "C:/Windows/Temp/packer/scripts/shutdown.cmd"
  shutdown_timeout = "10m"

  iso_urls = [
    "${var.download_directory}/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso",
    "https://software-download.microsoft.com/download/sg/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
  ]
  iso_checksum = "sha256:4f1457c4fe14ce48c9b2324924f33ca4f0470475e6da851b39ccbf98f44e7852"
  disk_size    = 130048
  cd_files     = ["builders/iso/attach/*"]
}

source "hyperv-iso" "default" {
  vm_name                          = local.vm_name
  generation                       = local.generation
  configuration_version            = local.configuration_version
  cpus                             = local.cpus
  enable_virtualization_extensions = local.enable_virtualization_extensions
  memory                           = local.memory
  enable_dynamic_memory            = local.enable_dynamic_memory
  switch_name                      = local.switch_name
  enable_mac_spoofing              = local.enable_mac_spoofing
  enable_secure_boot               = local.enable_secure_boot
  secure_boot_template             = local.secure_boot_template
  boot_wait                        = local.boot_wait
  boot_command                     = local.boot_command
  boot_keygroup_interval           = local.boot_keygroup_interval
  headless                         = local.headless

  communicator   = local.communicator_type
  winrm_username = local.communicator_username
  winrm_password = local.communicator_password
  winrm_timeout  = local.communicator_timeout

  shutdown_command = local.shutdown_command
  shutdown_timeout = local.shutdown_timeout

  iso_urls     = local.iso_urls
  iso_checksum = local.iso_checksum
  disk_size    = local.disk_size
  cd_files     = local.cd_files
}
