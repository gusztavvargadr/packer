packer {
  required_version = "~> 1.9"

  required_plugins {
    vagrant = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variables {
  author  = "gusztavvargadr"
  version = "2308.1.0"
}

variable "options" {
  type = map(map(string))
}

variable "configuration" {
  type = string
}

variable "provider" {
  type = string
}

variable "home_directory" {
  default = env("HOME")
}

variable "userprofile_directory" {
  default = env("USERPROFILE")
}

locals {
  timestamp = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
  download_directory = coalesce(var.home_directory, var.userprofile_directory)

  options = var.options[var.configuration]

  name        = local.options.name
  description = local.options.description

  vm_name  = "${var.author}-${local.name}-${var.version}-${local.timestamp}"
  headless = true

  cpus      = 4
  memory    = 8192
  disk_size = 130048
  iso_urls = [
    "${local.download_directory}/${local.options.iso_url_local}",
    local.options.iso_url_remote
  ]
  iso_checksum = local.options.iso_checksum
  cd_content = {
    "autounattend.xml" = templatefile("${path.root}/autounattend.xml", {
      image_name = local.options.iso_image_name
    })
    "autounattend-first-logon.ps1" = file("${path.root}/autounattend-first-logon.ps1")
  }
  boot_wait    = "1s"
  boot_command = ["<enter><wait><enter><wait><enter>"]

  communicator_type     = "ssh"
  communicator_username = "Administrator"
  communicator_password = "Packer42-"
  communicator_timeout  = "30m"

  shutdown_command         = "shutdown /s /t 10"
  vagrant_shutdown_command = "C:/Windows/Temp/packer/shutdown.cmd"
  shutdown_timeout         = "10m"
}

variable "chef_destination" {
  type    = string
  default = "C:/Windows/Temp/chef/"
}

variable "chef_max_retries" {
  type    = string
  default = "10"
}

variable "chef_start_retry_timeout" {
  type    = string
  default = "30m"
}

variable "packer_destination" {
  type    = string
  default = "C:/Windows/Temp/packer/"
}

locals {
  core_output_directory = "${path.root}/artifacts/${local.name}/${var.provider}-core"
  core_sources = {
    virtualbox = "virtualbox-iso.core"
    vmware     = "vmware-iso.core"
    hyperv     = "hyperv-iso.core"
    amazon     = "source.amazon-ebs.core"
  }
}

build {
  name = "core"

  sources = ["${lookup(local.core_sources, var.provider, "")}"]

  provisioner "powershell" {
    inline = ["mkdir -Force ${var.chef_destination}"]
  }

  provisioner "file" {
    source      = "${path.root}/chef/artifacts/"
    destination = "${var.chef_destination}"
  }

  provisioner "powershell" {
    script              = "${path.root}/chef/run.ps1"
    max_retries         = "${var.chef_max_retries}"
    pause_before         = "1m0s"
    start_retry_timeout = "${var.chef_start_retry_timeout}"

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

locals {
  vagrant_output_directory = "${path.root}/artifacts/${local.name}/${var.provider}-vagrant"
  vagrant_sources = {
    virtualbox = "virtualbox-ovf.core"
    vmware     = "vmware-vmx.core"
    hyperv     = "hyperv-vmcx.core"
    amazon     = "source.amazon-ebs.core"
  }
}

build {
  name = "vagrant"

  sources = ["${lookup(local.vagrant_sources, var.provider, "")}"]

  provisioner "powershell" {
    inline = ["mkdir -Force ${var.packer_destination}"]
  }

  provisioner "file" {
    source      = "${path.root}/vagrant/"
    destination = "${var.packer_destination}"
  }

  post-processors {
    post-processor "vagrant" {
      vagrantfile_template = "${path.root}/${var.provider}.Vagrantfile"
      output               = "${local.vagrant_output_directory}/vagrant.box"
    }

    post-processor "manifest" {
      output = "${local.vagrant_output_directory}/manifest.json"
    }

    post-processor "checksum" {
      checksum_types = ["sha256"]
      output         = "${local.vagrant_output_directory}/checksum.{{ .ChecksumType }}"
    }
  }
}
