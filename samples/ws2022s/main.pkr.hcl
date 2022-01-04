variables {
  author      = "gusztavvargadr"
  name        = "ws2022sc"
  description = "Windows Server 2022 Standard Core"
  version     = "2112.0.0"

  artifacts_directory = "output"
  download_directory  = "${env("HOME")}/Downloads"
}

locals {
  vm_name  = "${var.author}-${var.name}-${var.version}-${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
  cpus     = 2
  memory   = 4096
  headless = true

  disk_size = 130048
  iso_urls = [
    "${var.download_directory}/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso",
    "https://software-download.microsoft.com/download/sg/20348.169.210806-2348.fe_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
  ]
  iso_checksum = "sha256:4f1457c4fe14ce48c9b2324924f33ca4f0470475e6da851b39ccbf98f44e7852"
  cd_files = [
    "builders/iso/Autounattend.xml",
    "builders/iso/boot.ps1"
  ]

  boot_wait              = "1s"
  boot_command           = ["<enter><wait>", "<enter><wait>", "<enter><wait>"]
  boot_keygroup_interval = "1s"

  communicator_type     = "winrm"
  communicator_username = "Administrator"
  communicator_password = "Packer42-"
  communicator_timeout  = "30m"

  shutdown_command = "shutdown /s /t 10"
  shutdown_timeout = "10m"
}

locals {
  chef_host_directory     = "provisioners/chef"
  chef_guest_directory    = "C:/Windows/Temp/packer/${local.chef_host_directory}"
  chef_policies_directory = "policies"

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

  provisioner "shell-local" {
    inline = [
      "cd ${local.chef_host_directory}",
      "chef install",
      "chef export ${local.chef_policies_directory} --archive"
    ]
  }

  provisioner "powershell" {
    inline            = ["mkdir -Force ${local.chef_guest_directory}"]
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "file" {
    source      = "${local.chef_host_directory}/${local.chef_policies_directory}/"
    destination = "${local.chef_guest_directory}"
  }

  provisioner "powershell" {
    script            = "${local.chef_host_directory}/prepare.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CHEF_DIR=${local.chef_guest_directory}"
    ]
  }

  provisioner "powershell" {
    script            = "${local.chef_host_directory}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CHEF_DIR=${local.chef_guest_directory}",
      "PKR_CHEF_NAMED_RUN_LIST=prepare"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_host_directory}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CHEF_DIR=${local.chef_guest_directory}",
      "PKR_CHEF_NAMED_RUN_LIST=install"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_host_directory}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CHEF_DIR=${local.chef_guest_directory}",
      "PKR_CHEF_NAMED_RUN_LIST=patch"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_host_directory}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CHEF_DIR=${local.chef_guest_directory}",
      "PKR_CHEF_NAMED_RUN_LIST=patch"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_host_directory}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CHEF_DIR=${local.chef_guest_directory}",
      "PKR_CHEF_NAMED_RUN_LIST=patch"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_host_directory}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CHEF_DIR=${local.chef_guest_directory}",
      "PKR_CHEF_NAMED_RUN_LIST=patch"
    ]
  }

  provisioner "windows-restart" {
    restart_timeout = local.windows_restart_timeout
  }

  provisioner "powershell" {
    script            = "${local.chef_host_directory}/run.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CHEF_DIR=${local.chef_guest_directory}",
      "PKR_CHEF_NAMED_RUN_LIST=cleanup"
    ]
  }

  provisioner "powershell" {
    script            = "${local.chef_host_directory}/cleanup.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
    environment_vars = [
      "PKR_CHEF_DIR=${local.chef_guest_directory}"
    ]
  }

  post-processor "manifest" {
    output = "${var.artifacts_directory}/${source.name}/manifest.json"
  }

  post-processor "checksum" {
    checksum_types = ["sha256"]
    output         = "${var.artifacts_directory}/${source.name}/{{.ChecksumType}}.checksum"
  }
}
