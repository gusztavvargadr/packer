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

variable "build" {
  type = string
}

variable "home_directory" {
  default = env("HOME")
}

variable "userprofile_directory" {
  default = env("USERPROFILE")
}

locals {
  author  = var.author
  version = var.version

  options  = var.options[var.configuration]
  provider = var.provider
  build    = var.build

  timestamp           = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
  downloads_directory = "${coalesce(var.home_directory, var.userprofile_directory)}/Downloads"
}

locals {
  core_build    = local.build == "core"
  vagrant_build = local.build == "vagrant"
}

locals {
  core_iso    = contains(keys(local.options), "iso_checksum")
  core_export = contains(keys(local.options), "export")
}

locals {
  name        = local.options.name
  description = local.options.description

  vm_name  = "${local.author}-${local.name}-${local.version}-${local.timestamp}"
  headless = true

  cpus      = 4
  memory    = 8192
  disk_size = 130048
  iso_urls = [
    "${local.downloads_directory}/${lookup(local.options, "iso_url_local", "")}",
    lookup(local.options, "iso_url_remote", "")
  ]
  iso_checksum = lookup(local.options, "iso_checksum", "")
  cd_content = {
    "autounattend.xml" = templatefile("${path.root}/autounattend.xml", {
      image_names  = compact([lookup(local.options, "image_name", "")])
      product_keys = compact([lookup(local.options, "product_key", "")])
    })
    "autounattend-first-logon.ps1" = file("${path.root}/autounattend-first-logon.ps1")
  }
  boot_wait    = "1s"
  boot_command = ["<enter><wait><enter><wait><enter>"]

  communicator_type     = "ssh"
  communicator_username = "Administrator"
  communicator_password = "Packer42-"
  communicator_timeout  = "30m"

  core_shutdown_command    = "shutdown /s /t 10"
  vagrant_shutdown_command = "C:/Windows/Temp/packer/shutdown.cmd"
  shutdown_command         = local.core_build ? local.core_shutdown_command : local.vagrant_shutdown_command
  shutdown_timeout         = "10m"
}

locals {
  chef_destination         = "C:/Windows/Temp/chef/"
  chef_max_retries         = 10
  chef_start_retry_timeout = "30m"
}

locals {
  packer_destination = "C:/Windows/Temp/packer/"
}

locals {
  core_build_import_directory = local.core_build ? "${path.cwd}/../${lookup(local.options, "parent_type", "")}/artifacts/${lookup(local.options, "parent_configuration", "")}/${local.provider}-core" : ""
  vagrant_build_import_directory = local.vagrant_build ? "${path.cwd}/artifacts/${local.name}/${local.provider}-core" : ""
  import_directory = coalesce(local.core_build_import_directory, local.vagrant_build_import_directory)

  artifacts_directory = "${path.cwd}/artifacts/${local.name}/${local.provider}-${local.build}"
}

locals {
  core_iso_sources = {
    virtualbox = "virtualbox-iso.core"
    vmware     = "vmware-iso.core"
    hyperv     = "hyperv-iso.core"
  }

  core_import_sources = {
    virtualbox = "virtualbox-ovf.core"
    vmware     = "vmware-vmx.core"
    hyperv     = "hyperv-vmcx.core"
  }
}

source "null" "core" {
  communicator = "none"
}

build {
  name = "core"

  source "null.core" {
  }

  sources = local.core_build ? (local.core_iso ? compact([lookup(local.core_iso_sources, local.provider, "")]) : compact([lookup(local.core_import_sources, local.provider, "")])) : []

  provisioner "powershell" {
    script = "${path.root}/chef/initialize.ps1"

    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "file" {
    source      = "${path.cwd}/artifacts/chef/"
    destination = local.chef_destination
  }

  provisioner "powershell" {
    script              = "${path.root}/chef/execute.ps1"
    max_retries         = local.chef_max_retries
    pause_before        = "1m0s"
    start_retry_timeout = local.chef_start_retry_timeout

    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "powershell" {
    script = "${path.root}/chef/cleanup.ps1"

    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  post-processor "manifest" {
    output = "${local.artifacts_directory}/manifest.json"
  }

  post-processor "checksum" {
    checksum_types = ["sha256"]
    output         = "${local.artifacts_directory}/checksum.{{ .ChecksumType }}"
  }
}

locals {
  vagrant_import_sources = {
    virtualbox = "virtualbox-ovf.core"
    vmware     = "vmware-vmx.core"
    hyperv     = "hyperv-vmcx.core"
  }
}

build {
  name = "vagrant"

  source "null.core" {
  }

  sources = local.vagrant_build ? compact([lookup(local.vagrant_import_sources, local.provider, "")]) : []

  provisioner "powershell" {
    inline = ["mkdir -Force ${local.packer_destination}"]
  }

  provisioner "file" {
    source      = "${path.root}/vagrant/"
    destination = local.packer_destination
  }

  post-processors {
    post-processor "vagrant" {
      vagrantfile_template = "${path.root}/${local.provider}.Vagrantfile"
      output               = "${local.artifacts_directory}/vagrant.box"
    }

    post-processor "manifest" {
      output = "${local.artifacts_directory}/manifest.json"
    }

    post-processor "checksum" {
      checksum_types = ["sha256"]
      output         = "${local.artifacts_directory}/checksum.{{ .ChecksumType }}"
    }
  }
}
