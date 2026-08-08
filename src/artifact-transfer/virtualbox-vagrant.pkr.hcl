packer {
  required_plugins {
    vagrant = {
      version = "= 1.1.6"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variable "architecture" {
  type = string
}

variable "artifact_root" {
  type = string
}

variable "canonical_root" {
  type = string
}

locals {
  architecture_input   = var.architecture
  artifact_root_input  = var.artifact_root
  canonical_root_input = var.canonical_root

  canonical_image_files = [
    for relative_path in fileset(local.canonical_root_input, "image/*") :
    "${local.canonical_root_input}/${relative_path}"
  ]
}

source "null" "virtualbox" {
  communicator = "none"
}

build {
  name = "virtualbox-vagrant-package"

  sources = ["null.virtualbox"]

  post-processors {
    post-processor "artifice" {
      files = local.canonical_image_files
    }

    post-processor "vagrant" {
      architecture         = local.architecture_input
      output               = "${local.artifact_root_input}/vagrant/vagrant.box"
      provider_override    = "virtualbox"
      vagrantfile_template = "${local.artifact_root_input}/Vagrantfile"
    }

    post-processor "manifest" {
      output = "${local.artifact_root_input}/manifest.json"
    }

    post-processor "checksum" {
      checksum_types = ["sha256"]
      output         = "${local.artifact_root_input}/checksum.{{ .ChecksumType }}"
    }
  }
}
