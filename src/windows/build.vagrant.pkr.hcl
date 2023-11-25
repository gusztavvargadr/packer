packer {
  required_plugins {
    vagrant = {
      version = "~> 1.1"
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

  source_options_vagrant = {
    iso_urls     = []
    iso_checksum = ""
    cd_content   = {}

    import_directory = local.vagrant_build ? "${path.cwd}/artifacts/${var.image}/${local.image_provider}/native" : ""

    boot_command     = compact([])
    shutdown_command = "C:/Windows/Temp/packer/shutdown.cmd"
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

source "file" "Vagrantfile" {
  content = templatefile("${path.root}/vagrant/template.Vagrantfile", { options = local.vagrant_options })
  target  = "${local.artifacts_directory}/Vagrantfile"
}

build {
  name = "vagrant-restore"

  sources = ["file.Vagrantfile"]
}

locals {
  packer_destination = "C:/Windows/Temp/packer/"
}

build {
  name = "vagrant-build"

  sources = local.vagrant_build ? compact([lookup(local.vagrant_import_sources, local.image_provider, "")]) : ["null.core"]

  provisioner "powershell" {
    inline = ["mkdir -Force ${local.packer_destination}"]
  }

  provisioner "file" {
    source      = "${path.root}/vagrant/"
    destination = local.packer_destination
  }

  post-processors {
    post-processor "vagrant" {
      vagrantfile_template = "${local.artifacts_directory}/Vagrantfile"
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

build {
  name = "vagrant-test"

  sources = ["null.core"]

  provisioner "shell-local" {
    inline = [
      "vagrant destroy -f local",
      "vagrant box remove gusztavvargadr/local"
    ]

    valid_exit_codes = [0, 1]

    env = {
      VAGRANT_BOX_URL = "${local.artifacts_directory}/vagrant/vagrant.box"
    }
  }

  provisioner "shell-local" {
    inline = [
      "vagrant up local"
    ]

    max_retries = 1

    env = {
      VAGRANT_BOX_URL = "${local.artifacts_directory}/vagrant/vagrant.box"
    }
  }

  provisioner "shell-local" {
    inline = [
      "vagrant destroy -f local",
      "vagrant box remove gusztavvargadr/local"
    ]

    valid_exit_codes = [0, 1]

    env = {
      VAGRANT_BOX_URL = "${local.artifacts_directory}/vagrant/vagrant.box"
    }
  }
}

build {
  name = "vagrant-publish"

  sources = ["null.core"]

  post-processors {
    post-processor "artifice" {
      files = ["${local.artifacts_directory}/vagrant/vagrant.box"]
    }

    post-processor "vagrant-cloud" {
      box_tag    = "${var.author}/${local.image_name}"
      version    = local.image_version
      no_release = true
    }
  }
}
