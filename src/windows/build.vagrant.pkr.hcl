packer {
  required_plugins {
    vagrant = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/vagrant"
    }
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
      vagrantfile_template = "${path.root}/vagrant/${local.provider}.Vagrantfile"
      output               = "${local.artifacts_directory}/vagrant/vagrant.box"
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
