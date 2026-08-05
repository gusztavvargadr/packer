packer {
  required_plugins {
    virtualbox = {
      version = "= 1.1.5"
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

source "virtualbox-iso" "fixture" {
  vm_name          = var.vm_name
  output_directory = var.output_directory

  chipset              = var.arm64 ? "armv8virtual" : "piix3"
  firmware             = "efi"
  gfx_controller       = var.arm64 ? "qemuramfb" : "vmsvga"
  guest_os_type        = var.arm64 ? "Other_arm64" : "Other_64"
  cpus                 = 1
  memory               = 128
  disk_size            = 16
  iso_url              = var.iso_url
  iso_checksum         = "none"
  iso_interface        = "sata"
  hard_drive_interface = "sata"

  audio_controller        = "none"
  boot_wait               = "0s"
  communicator            = "none"
  guest_additions_mode    = "disable"
  headless                = true
  keep_registered         = true
  keyboard                = var.arm64 ? "usb" : "ps2"
  mouse                   = var.arm64 ? "usb" : "ps2"
  shutdown_timeout        = "30s"
  skip_export             = true
  usb                     = var.arm64
  usb_controller          = "xhci"
  vboxmanage              = var.arm64 ? [["storagectl", "{{.Name}}", "--name", "IDE", "--remove"]] : []
  vboxmanage_post         = var.fail_build ? [["modifyvm", "{{.Name}}", "--definitely-invalid-option", "on"]] : []
  virtualbox_version_file = ""
}

build {
  sources = ["source.virtualbox-iso.fixture"]
}
