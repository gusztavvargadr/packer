packer {
  required_plugins {
    vagrant = {
      version = "~> 1.1"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

variable "box_artifact_destination" {
  type        = string
  description = "The rclone destination root for published Vagrant boxes."
  default     = "r2:packer"
}

variable "box_artifact_origin" {
  type        = string
  description = "The public origin for published Vagrant boxes."
  default     = "https://pub-8fcabe1edc344cb782c6dafddb0fe446.r2.dev"
}

locals {
  box_artifact_destination = var.box_artifact_destination
  box_artifact_origin      = var.box_artifact_origin

  vagrant_import_sources = {
    virtualbox = "virtualbox-ovf.core"
    vmware     = "vmware-vmx.core"
    hyperv     = "hyperv-vmcx.core"
    qemu       = "qemu.import"
  }

  source_options_vagrant = {
    iso_urls     = []
    iso_checksum = ""
    cd_content   = {}

    import_directory = local.vagrant_build ? "${local.artifacts_directory}/../native" : ""

    boot_command     = compact([])
    shutdown_command = "C:/Windows/Temp/packer/shutdown.cmd"
  }

  vagrant_providers = {
    virtualbox = "virtualbox"
    vmware     = "vmware_desktop"
    hyperv     = "hyperv"
    qemu       = "libvirt"
  }

  vagrant_box_name       = lookup(local.vagrant_options, "box_name", replace(local.image_name, "/", "-"))
  vagrant_box_provider   = lookup(local.vagrant_providers, local.image_provider, "")
  vagrant_box_object_key = "${local.vagrant_box_name}/${local.image_version}/${local.vagrant_box_provider}/${local.image_architecture}/vagrant.box"
}

locals {
  vagrant_options_core = {
    cpus   = "2"
    memory = "2048"
    ports  = "3389"
  }
  vagrant_options_image = lookup(local.image_options, "vagrant", {})
  vagrant_options       = merge(local.vagrant_options_core, local.vagrant_options_image)

  vagrant_default_architecture       = lookup(local.vagrant_options, "default_architecture", "amd64")
  vagrant_alias_default_architecture = lookup(local.vagrant_options, "alias_default_architecture", local.vagrant_default_architecture)
}

source "file" "Vagrantfile" {
  content = templatefile("${path.root}/vagrant/${local.image_provider}.Vagrantfile", {
    options          = local.vagrant_options
    provider_options = lookup(local.image_options, local.image_provider, {})
  })
  target = "${local.artifacts_directory}/Vagrantfile"
}

source "file" "Autounattend" {
  content = templatefile("${path.root}/vagrant/Autounattend.xml", { architecture = local.image_architecture })
  target  = "${local.artifacts_directory}/Autounattend.xml"
}

build {
  name = "vagrant-restore"

  sources = ["file.Vagrantfile", "file.Autounattend"]
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

  provisioner "file" {
    source      = "${local.artifacts_directory}/Autounattend.xml"
    destination = "${local.packer_destination}/Autounattend.xml"
  }

  provisioner "powershell" {
    script = "${path.root}/vagrant/cleanup.ps1"

    elevated_user     = local.communicator.username
    elevated_password = local.communicator.password
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
      "vagrant destroy -f ${var.image}",
    ]

    valid_exit_codes = [0, 1]

    env = {
      VAGRANT_BOX_URL = "${local.artifacts_directory}/vagrant/vagrant.box"
    }
  }

  provisioner "shell-local" {
    inline = [
      "vagrant up ${var.image} --provider ${lookup(local.vagrant_providers, local.image_provider, "")}",
    ]

    max_retries = 1

    env = {
      VAGRANT_BOX_URL = "${local.artifacts_directory}/vagrant/vagrant.box"
    }
  }

  provisioner "shell-local" {
    inline = [
      "vagrant destroy -f ${var.image}",
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

  provisioner "shell-local" {
    inline = [
      "rclone copyto \"${local.artifacts_directory}/vagrant/vagrant.box\" \"${local.box_artifact_destination}/${local.vagrant_box_object_key}\" --verbose --checksum --immutable",
    ]
  }

  post-processors {
    post-processor "artifice" {
      files = ["${local.artifacts_directory}/vagrant/vagrant.box"]
    }

    post-processor "vagrant-registry" {
      box_tag              = "${local.image_author}/${local.vagrant_box_name}"
      version              = local.image_version
      box_download_url     = "${local.box_artifact_origin}/${local.vagrant_box_object_key}"
      box_checksum         = "SHA256:${split("\t", file("${local.artifacts_directory}/checksum.sha256"))[0]}"
      architecture         = local.image_architecture
      default_architecture = local.vagrant_default_architecture
      // no_release           = true
    }
  }

  dynamic "post-processors" {
    for_each = compact([lookup(local.vagrant_options, "box_alias", "")])

    content {
      post-processor "artifice" {
        files = ["${local.artifacts_directory}/vagrant/vagrant.box"]
      }

      post-processor "vagrant-registry" {
        box_tag              = "${local.image_author}/${post-processors.value}"
        version              = local.image_version
        box_download_url     = "https://vagrantcloud.com/${local.image_author}/boxes/${lookup(local.vagrant_options, "box_name", replace(local.image_name, "/", "-"))}/versions/${local.image_version}/providers/${lookup(local.vagrant_providers, local.image_provider, "")}/${local.image_architecture}/vagrant.box"
        box_checksum         = "SHA256:${split("\t", file("${local.artifacts_directory}/checksum.sha256"))[0]}"
        architecture         = local.image_architecture
        default_architecture = local.vagrant_alias_default_architecture
        // no_release           = true
      }
    }
  }
}

build {
  name = "vagrant-download"

  sources = ["null.core"]

  provisioner "shell-local" {
    inline = [
      "vagrant destroy -f ${var.image}",
    ]

    valid_exit_codes = [0, 1]
  }

  provisioner "shell-local" {
    inline = [
      "vagrant up ${var.image} --provider ${lookup(local.vagrant_providers, local.image_provider, "")}",
    ]

    max_retries = 1
  }

  provisioner "shell-local" {
    inline = [
      "vagrant destroy -f ${var.image}",
    ]

    valid_exit_codes = [0, 1]
  }
}
