locals {
  native_iso_sources = {
    virtualbox = "virtualbox-iso.core"
    vmware     = "vmware-iso.core"
    hyperv     = "hyperv-iso.core"
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
      "chef install",
      "chef update --attributes",
      "chef export ${local.artifacts_directory}/chef --force"
    ]

    env = {
      CHEF_LICENSE = "accept-silent"
    }
  }
}

locals {
  chef_destination         = "/opt/packer-build/chef/"
  chef_max_retries         = 10
  chef_start_retry_timeout = "30m"
  chef_attributes          = lookup(local.image_options.native, "chef_attributes", "")
}

build {
  name = "native-build"

  sources = local.native_build ? (local.native_iso ? compact([lookup(local.native_iso_sources, local.image_provider, "")]) : compact([lookup(local.native_import_sources, local.image_provider, "")])) : ["null.core"]

  provisioner "shell" {
    script            = "${path.root}/chef/initialize.sh"
    expect_disconnect = true
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
    script              = "${path.root}/chef/provision.sh"
    max_retries         = local.chef_max_retries
    pause_before        = "90s"
    start_retry_timeout = local.chef_start_retry_timeout

    env = {
      CHEF_ATTRIBUTES = local.chef_attributes
    }
  }

  provisioner "shell" {
    execute_command   = "{{.Vars}} sudo -S -E bash -eux '{{.Path}}'"
    expect_disconnect = true

    scripts = [
      "${path.root}/chef/scripts/shell-configure/sshd.sh",
      "${path.root}/chef/scripts/shell-configure/networking.sh",
    ]
  }

  provisioner "shell" {
    execute_command   = "{{.Vars}} sudo -S -E bash -eux '{{.Path}}'"
    expect_disconnect = true

    scripts = [
      "${path.root}/chef/scripts/shell-cleanup/cleanup.sh",
      "${path.root}/chef/scripts/shell-cleanup/minimize.sh",
    ]
  }

  // provisioner "powershell" {
  //   script = "${path.root}/chef/cleanup.ps1"

  //   elevated_user     = local.communicator.username
  //   elevated_password = local.communicator.password
  // }

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
