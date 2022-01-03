variables {
  author      = "gusztavvargadr"
  name        = "ws2022sc"
  description = "Windows Server 2022 Standard Core"
  version     = "2112.0.0"

  artifacts_directory = "output"
  download_directory  = "${env("HOME")}/Downloads"
}

locals {
  vm_name = "${var.author}-${var.name}-${var.version}-${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
  cpus    = 2
  memory  = 4096

  boot_wait              = "1s"
  boot_command           = ["<enter><wait>", "<enter><wait>", "<enter><wait>"]
  boot_keygroup_interval = "1s"
  headless               = true

  communicator_type     = "winrm"
  communicator_username = "Administrator"
  communicator_password = "Packer42-"
  communicator_timeout  = "30m"

  shutdown_command = "shutdown /s /t 10"
  shutdown_timeout = "10m"

  iso_urls = [
    "${var.download_directory}/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso",
    "https://software-download.microsoft.com/download/sg/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
  ]
  iso_checksum = "sha256:4f1457c4fe14ce48c9b2324924f33ca4f0470475e6da851b39ccbf98f44e7852"
  disk_size    = 130048
  cd_files = [
    "builders/iso/Autounattend.xml",
    "builders/iso/boot.ps1"
  ]
}

locals {
  chef_file_source      = "provisioners/chef"
  chef_file_destination = "C:/Windows/Temp/packer/${local.chef_file_source}"

  windows_restart_timeout = "30m"
}

build {
  source "hyperv-iso.default" {
    name             = "hyperv-core"
    output_directory = "${var.artifacts_directory}/${source.name}/image"
  }

  source "virtualbox-iso.default" {
    name             = "virtualbox-core"
    output_directory = "${var.artifacts_directory}/${source.name}/image"
  }

  provisioner "powershell" {
    inline            = ["mkdir -Force ${local.chef_file_destination}"]
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "file" {
    source      = "${local.chef_file_source}/policies"
    destination = "${local.chef_file_destination}"
  }

  provisioner "powershell" {
    script            = "${local.chef_file_source}/prepare.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CWD=${local.chef_file_destination}"
    ]
  }

  provisioner "powershell" {
    script            = "${local.chef_file_source}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CWD=${local.chef_file_destination}",
      "PKR_CHEF_NAMED_RUN_LIST=prepare"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_file_source}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CWD=${local.chef_file_destination}",
      "PKR_CHEF_NAMED_RUN_LIST=install"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_file_source}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CWD=${local.chef_file_destination}",
      "PKR_CHEF_NAMED_RUN_LIST=patch"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_file_source}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CWD=${local.chef_file_destination}",
      "PKR_CHEF_NAMED_RUN_LIST=patch"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_file_source}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CWD=${local.chef_file_destination}",
      "PKR_CHEF_NAMED_RUN_LIST=patch"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_file_source}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CWD=${local.chef_file_destination}",
      "PKR_CHEF_NAMED_RUN_LIST=patch"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_file_source}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CWD=${local.chef_file_destination}",
      "PKR_CHEF_NAMED_RUN_LIST=clenaup"
    ]
  }

  provisioner "powershell" {
    script            = "${local.chef_file_source}/cleanup.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  post-processor "manifest" {
    output = "${var.artifacts_directory}/${source.name}/manifest.json"
  }

  post-processor "checksum" {
    checksum_types = ["sha256"]
    output         = "${var.artifacts_directory}/${source.name}/{{.ChecksumType}}.checksum"
  }
}
