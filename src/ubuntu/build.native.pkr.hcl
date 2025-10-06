variable "userprofile_directory" {
  type    = string
  default = env("USERPROFILE")
}

variable "home_directory" {
  type    = string
  default = env("HOME")
}

locals {
  native_iso_sources = {
    virtualbox = "virtualbox-iso.core"
    vmware     = "vmware-iso.core"
    hyperv     = "hyperv-iso.core"
    qemu       = "qemu.iso"
  }

  native_import_sources = {
    virtualbox = "virtualbox-ovf.core"
    vmware     = "vmware-vmx.core"
    hyperv     = "hyperv-vmcx.core"
  }

  native_iso          = contains(keys(local.image_options.native), "source_iso_checksum")
  downloads_directory = "${coalesce(var.userprofile_directory, var.home_directory)}/Downloads"

  source_options_native = {
    iso_urls = local.native_iso ? [
      "${local.downloads_directory}/${local.image_options.native.source_iso_url_local}",
      local.image_options.native.source_iso_url_remote
    ] : []
    iso_checksum   = local.native_iso ? local.image_options.native.source_iso_checksum : ""
    http_directory = "${path.root}/boot"

    import_directory = local.native_build ? "${path.cwd}/../../artifacts/${lookup(local.image_options.native, "source_image", "")}/${local.image_provider}/native" : ""

    boot_command = local.native_iso ? [
      "c<wait>",
      "set gfxpayload=keep<enter><wait>",
      "linux /casper/vmlinuz quiet autoinstall 'ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${local.image_provider}/'<enter><wait>",
      "initrd /casper/initrd<enter><wait>",
      "boot<enter>wait>",
    ] : []
    shutdown_command = "sudo -S shutdown -P now"
  }
}

build {
  name = "native-restore"

  sources = ["null.core"]

  provisioner "shell-local" {
    inline = [
      "chef install --chef-license accept-silent",
      "chef update --attributes",
      "chef export ${local.artifacts_directory}/chef --force"
    ]
  }
}

locals {
  chef_destination = "/var/tmp/packer-build/chef/"
  chef_max_retries = 10
  chef_attributes  = lookup(local.image_options.native, "chef_attributes", "")
  chef_keep        = lookup(local.image_options.native, "chef_keep", "false")
}

build {
  name = "native-build"

  sources = local.native_build ? (local.native_iso ? compact([lookup(local.native_iso_sources, local.image_provider, "")]) : compact([lookup(local.native_import_sources, local.image_provider, "")])) : ["null.core"]

  provisioner "shell" {
    script = "${path.root}/chef/initialize.sh"
  }

  provisioner "file" {
    source      = "${local.artifacts_directory}/chef/"
    destination = local.chef_destination
  }

  provisioner "file" {
    sources     = fileset(path.cwd, "attributes.*.json")
    destination = local.chef_destination
  }

  provisioner "shell" {
    script           = "${path.root}/chef/apply.sh"
    valid_exit_codes = [0, 35]

    env = {
      CHEF_ATTRIBUTES = local.chef_attributes
    }
  }

  provisioner "shell" {
    inline = ["sudo shutdown --reboot +1"]
  }

  provisioner "shell" {
    script       = "${path.root}/chef/apply.sh"
    max_retries  = local.chef_max_retries
    pause_before = "120s"

    env = {
      CHEF_ATTRIBUTES = local.chef_attributes
    }
  }

  provisioner "shell" {
    script            = "${path.root}/chef/cleanup.sh"
    expect_disconnect = true

    env = {
      CHEF_KEEP = local.chef_keep
    }
  }

  post-processor "manifest" {
    output = "${local.artifacts_directory}/manifest.json"
  }

  post-processor "checksum" {
    checksum_types = ["sha256"]
    output         = "${local.artifacts_directory}/checksum.{{ .ChecksumType }}"
  }
}

build {
  name = "native-test"

  sources = ["null.core"]
}

build {
  name = "native-publish"

  sources = ["null.core"]
}
