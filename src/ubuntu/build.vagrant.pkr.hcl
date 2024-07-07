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
    iso_urls       = []
    iso_checksum   = ""
    http_directory = ""

    import_directory = local.vagrant_build ? "${local.artifacts_directory}/../native" : ""

    boot_command     = compact([])
    shutdown_command = "sudo -S shutdown -P now"
  }

  vagrant_providers = {
    virtualbox = "virtualbox"
    vmware     = "vmware_desktop"
    hyperv     = "hyperv"
  }
}

locals {
  vagrant_options_core = {
    cpus         = "2"
    memory       = "2048"
    ports        = ""
    architecture = "amd64"
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

build {
  name = "vagrant-build"

  sources = local.vagrant_build ? compact([lookup(local.vagrant_import_sources, local.image_provider, "")]) : ["null.core"]

  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/vagrant"
    ]
    execute_command   = "{{.Vars}} sudo -S -E bash -eux '{{.Path}}'"
    expect_disconnect = true
    scripts = [
      "${path.root}/vagrant/vagrant.sh"
    ]
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

  post-processors {
    post-processor "artifice" {
      files = ["${local.artifacts_directory}/vagrant/vagrant.box"]
    }

    post-processor "vagrant-registry" {
      box_tag              = "${local.image_author}/${lookup(local.vagrant_options, "box_name", replace(local.image_name, "/", "-"))}"
      version              = local.image_version
      // box_checksum         = "sha256:${split("\t", file("${local.artifacts_directory}/checksum.sha256"))[0]}"
      architecture         = local.vagrant_options.architecture
      default_architecture = local.vagrant_options.architecture
      no_release           = true
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
        box_download_url     = "https://app.vagrantup.com/${local.image_author}/boxes/${lookup(local.vagrant_options, "box_name", replace(local.image_name, "/", "-"))}/versions/${local.image_version}/providers/${lookup(local.vagrant_providers, local.image_provider, "")}/${local.vagrant_options.architecture}/vagrant.box"
        // box_checksum         = "sha256:${split("\t", file("${local.artifacts_directory}/checksum.sha256"))[0]}"
        architecture         = local.vagrant_options.architecture
        default_architecture = local.vagrant_options.architecture
        no_release           = true
      }
    }
  }
}
