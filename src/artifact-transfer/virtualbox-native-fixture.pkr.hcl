packer {
  required_plugins {
    virtualbox = {
      version = "~> 1.1.4"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "arm64" {
  type = bool
}

variable "fail_build" {
  type    = bool
  default = false
}

variable "iso_url" {
  type = string
}

variable "output_directory" {
  type = string
}

variable "vm_name" {
  type = string
}

locals {
  arm64_input            = var.arm64
  fail_build_input       = var.fail_build
  iso_url_input          = var.iso_url
  output_directory_input = var.output_directory
  vm_name_input          = var.vm_name
}

source "virtualbox-iso" "fixture" {
  vm_name          = local.vm_name_input
  output_directory = local.output_directory_input

  chipset              = local.arm64_input ? "armv8virtual" : "piix3"
  firmware             = "efi"
  gfx_controller       = local.arm64_input ? "qemuramfb" : "vmsvga"
  guest_os_type        = local.arm64_input ? "Other_arm64" : "Other_64"
  cpus                 = 1
  memory               = 128
  disk_size            = 16
  iso_url              = local.iso_url_input
  iso_checksum         = "none"
  iso_interface        = "sata"
  hard_drive_interface = "sata"

  audio_controller        = "none"
  boot_wait               = "0s"
  communicator            = "none"
  guest_additions_mode    = "disable"
  headless                = true
  keep_registered         = true
  keyboard                = local.arm64_input ? "usb" : "ps2"
  mouse                   = local.arm64_input ? "usb" : "ps2"
  shutdown_timeout        = "30s"
  skip_export             = true
  usb                     = local.arm64_input
  usb_controller          = "xhci"
  vboxmanage              = local.arm64_input ? [["storagectl", "{{.Name}}", "--name", "IDE", "--remove"]] : []
  vboxmanage_post         = local.fail_build_input ? [["modifyvm", "{{.Name}}", "--definitely-invalid-option", "on"]] : []
  virtualbox_version_file = ""
}

build {
  sources = ["source.virtualbox-iso.fixture"]
}
