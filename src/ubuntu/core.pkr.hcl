packer {
  required_version = "~> 1.9"
}

variable "author" {
  type    = string
  default = "gusztavvargadr"
}

variable "version" {
  type    = string
  default = "2310v2"
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
    iso_checksum   = local.core_iso ? local.image_options.core.iso_checksum : ""
    http_directory = "${path.root}/boot"

    // boot_command     = local.core_build ? ["<wait><esc><wait>set gfxpayload=1024x768<enter>linux /install/vmlinuz preseed/url=http://{{.HTTPIP}}:{{.HTTPPort}}/${local.provider}.preseed.cfg debian-installer=en_US auto locale=en_US kbd-chooser/method=us hostname=vagrant fb=false debconf/frontend=noninteractive keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false <enter>initrd /install/initrd.gz<enter>boot<enter>"] : []
    // boot_command     = local.core_build ? [
    //   "<esc><wait>",
    //   "set gfxpayload=keep<enter><wait>",
	  //   "linux /casper/vmlinuz quiet autoinstall 'ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${local.provider}/'<enter><wait>",
    // 	"initrd /casper/initrd<enter><wait>",
    //   "boot<enter>wait>",
    // ] : []
    boot_command     = local.core_build ? [
      "<esc><wait>c<wait>",
      "set gfxpayload=keep<enter><wait>",
	    "linux /casper/vmlinuz quiet autoinstall 'ds=nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${local.provider}/'<enter><wait>",
    	"initrd /casper/initrd<enter><wait>",
      "boot<enter>wait>",
    ] : []
    boot_wait        = "2s"
    shutdown_command    = "echo 'vagrant' | sudo -S shutdown -P now"
    shutdown_timeout = "5m"
  }
}

locals {
  vagrant_options_core = {
    cpus   = 2
    memory = 2048
    ports  = []
  }
  vagrant_options_image = lookup(local.image_options, "vagrant", {})
  vagrant_options       = merge(local.vagrant_options_core, local.vagrant_options_image)
}

locals {
  communicator = {
    type     = "ssh"
    username = "vagrant"
    password = "vagrant"
    timeout  = "15m"
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
