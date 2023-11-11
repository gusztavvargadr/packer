packer {
  required_version = "~> 1.9"
}

variable "author" {
  type    = string
  default = "gusztavvargadr"
}

variable "version" {
  type    = string
  default = "2311"
}

variable "image" {
  type = string
}

variable "provider" {
  type = string
}

variable "build" {
  type = string
}

variable "images" {
  type = map(map(map(string)))
}

variable "home_directory" {
  type    = string
  default = env("HOME")
}

variable "userprofile_directory" {
  type    = string
  default = env("USERPROFILE")
}

locals {
  author   = var.author
  version  = var.version
  image    = var.image
  provider = var.provider
  build    = var.build

  image_options = var.images[local.image]

  downloads_directory = "${coalesce(var.home_directory, var.userprofile_directory)}/Downloads"

  timestamp = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"
}

locals {
  core_build    = local.build == "core"
  vagrant_build = local.build == "vagrant"
}

locals {
  core_iso = contains(keys(local.image_options.core), "iso_checksum")
}

locals {
  name        = local.image_options.core.name
  description = local.image_options.core.description
}

locals {
  artifacts_directory      = "${path.cwd}/artifacts/${local.name}/${local.provider}-${local.build}"
  iso_name                 = lookup(local.image_options.core, "iso_name", "")
  core_shutdown_command    = "shutdown /s /t 10"
  vagrant_shutdown_command = "C:/Windows/Temp/packer/shutdown.cmd"

  core_source_options = {
    vm_name          = "${local.author}-${local.name}-${local.version}-${local.timestamp}"
    headless         = true
    output_directory = "${local.artifacts_directory}/image"

    cpus      = 4
    memory    = 8192
    disk_size = 130048
    iso_urls = local.core_iso ? [
      "${local.downloads_directory}/${local.image_options.core.iso_url_local}",
      local.image_options.core.iso_url_remote
    ] : []
    iso_checksum = local.core_iso ? local.image_options.core.iso_checksum : ""
    cd_content = merge({
      "autounattend.xml"             = templatefile("${path.root}/boot/autounattend.xml", { core = local.image_options.core })
      "autounattend-first-logon.ps1" = templatefile("${path.root}/boot/autounattend-first-logon.ps1", { core = local.image_options.core })
      }, {
      for setup_script in compact([lookup(local.image_options.core, "setup_script", "")]) : setup_script => file("${path.cwd}/${setup_script}")
    })

    boot_command     = local.core_build ? (local.core_iso ? ["<enter><wait><enter><wait><enter>"] : []) : []
    boot_wait        = "1s"
    shutdown_command = local.core_build ? local.core_shutdown_command : local.vagrant_shutdown_command
    shutdown_timeout = "10m"
  }
}

locals {
  vagrant_options_core = {
    cpus   = "2"
    memory = "2048"
    ports  = "3389"
  }
  vagrant_options_image = lookup(local.image_options, "vagrant", {})
  vagrant_options       = merge(local.vagrant_options_core, local.vagrant_options_image)
}

locals {
  communicator = {
    type     = "ssh"
    username = "Administrator"
    password = "Packer42-"
    timeout  = "30m"
  }
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
  core_build_import_directory    = local.core_build ? "${path.cwd}/../${lookup(local.image_options.core, "import_directory", "")}/artifacts/${lookup(local.image_options.core, "import_image", "")}/${local.provider}-core" : ""
  vagrant_build_import_directory = local.vagrant_build ? "${path.cwd}/artifacts/${local.name}/${local.provider}-core" : ""
  import_directory               = coalesce(local.core_build_import_directory, local.vagrant_build_import_directory)
}

source "null" "core" {
  communicator = "none"
}
