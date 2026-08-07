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

locals {
  architecture_input  = var.architecture
  artifact_root_input = var.artifact_root

  canonical_image_files = [
    for relative_path in fileset(local.artifact_root_input, "image/*") :
    "${local.artifact_root_input}/${relative_path}"
  ]
  vagrant_box_output      = "${local.artifact_root_input}/vagrant/vagrant.box"
  vagrant_checksum_output = "${local.artifact_root_input}/checksum.{{ .ChecksumType }}"
  vagrant_manifest_output = "${local.artifact_root_input}/manifest.json"
  vagrantfile_template    = "${local.artifact_root_input}/Vagrantfile"
}

source "null" "sparse" {
  communicator = "none"
}

build {
  name = "virtualbox-vagrant-sparse-package"

  sources = ["null.sparse"]

  post-processors {
    post-processor "artifice" {
      files = local.canonical_image_files
    }

    post-processor "vagrant" {
      architecture         = local.architecture_input
      output               = local.vagrant_box_output
      provider_override    = "virtualbox"
      vagrantfile_template = local.vagrantfile_template
    }

    post-processor "manifest" {
      output = local.vagrant_manifest_output
    }

    post-processor "checksum" {
      checksum_types = ["sha256"]
      output         = local.vagrant_checksum_output
    }
  }
}
