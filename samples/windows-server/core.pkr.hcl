variables {
  author      = "gusztavvargadr"
  name        = "ws2022sc"
  description = "Windows Server 2022 Standard Core"
  version     = "2304.0.0"

  download_directory = "${env("HOME")}/Downloads"
}

variable "provider" {
  type = string
}

locals {
  timestamp = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
}

locals {
  vm_name               = "${var.author}-${var.name}-${var.version}-${local.timestamp}"
  headless              = true
  core_output_directory = "${path.root}/build/${var.name}/${var.provider}-core"

  cpus      = 4
  memory    = 8192
  disk_size = 130048
  iso_urls = [
    "${var.download_directory}/SERVER_EVAL_x64FRE_en-us.iso",
    "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
  ]
  iso_checksum = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  cd_content = {
    "autounattend.xml"             = file("${path.root}/autounattend.xml")
    "autounattend-first-logon.ps1" = file("${path.root}/autounattend-first-logon.ps1")
  }
  boot_wait    = "1s"
  boot_command = ["<enter><wait><enter><wait><enter>"]

  communicator_type     = "ssh"
  communicator_username = "Administrator"
  communicator_password = "Packer42-"
  communicator_timeout  = "30m"

  shutdown_command = "shutdown /s /t 10"
  shutdown_timeout = "10m"

  // clone_from_vmcx_path = "output/hyperv-core/image"
}

// locals {
//   chef_host_directory     = "provisioners/chef"
//   chef_guest_directory    = "C:/Windows/Temp/packer/${local.chef_host_directory}"
//   chef_policies_directory = "policies"

//   windows_restart_timeout = "30m"
// }

build {
  name        = "${var.name}-core"
  description = "${var.description} Core"

  sources = ["${var.provider}-iso.core"]

  provisioner "powershell" {
    script = "${path.root}/chef/prepare.ps1"

    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "powershell" {
    script = "${path.root}/chef/clean.ps1"

    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  post-processor "manifest" {
    output = "${local.core_output_directory}/manifest.json"
  }

  post-processor "checksum" {
    checksum_types = ["sha256"]
    output         = "${local.core_output_directory}/checksum.{{ .ChecksumType }}"
  }
}
