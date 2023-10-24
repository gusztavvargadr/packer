locals {
  core_iso_sources = {
    virtualbox = "virtualbox-iso.core"
    vmware     = "vmware-iso.core"
    hyperv     = "hyperv-iso.core"
  }

  core_import_sources = {
    virtualbox = "virtualbox-ovf.core"
    vmware     = "vmware-vmx.core"
    hyperv     = "hyperv-vmcx.core"
  }
}

build {
  name = "core-restore"

  sources = ["null.core"]

  provisioner "shell-local" {
    inline = [
      "chef install",
      "chef export ${local.artifacts_directory}/chef --force"
    ]
  }
}

build {
  name = "core-image"

  sources = local.core_build ? (local.core_iso ? compact([lookup(local.core_iso_sources, local.provider, "")]) : compact([lookup(local.core_import_sources, local.provider, "")])) : ["null.core"]

  provisioner "powershell" {
    script = "${path.root}/chef/initialize.ps1"

    elevated_user     = local.communicator.username
    elevated_password = local.communicator.password
  }

  provisioner "file" {
    source      = "${local.artifacts_directory}/chef/"
    destination = local.chef_destination
  }

  provisioner "powershell" {
    script              = "${path.root}/chef/provision.ps1"
    max_retries         = local.chef_max_retries
    pause_before        = "1m0s"
    start_retry_timeout = local.chef_start_retry_timeout

    elevated_user     = local.communicator.username
    elevated_password = local.communicator.password
  }

  provisioner "powershell" {
    script = "${path.root}/chef/cleanup.ps1"

    elevated_user     = local.communicator.username
    elevated_password = local.communicator.password
  }

  post-processor "manifest" {
    output = "${local.artifacts_directory}/manifest.json"
  }

  post-processor "checksum" {
    checksum_types = ["sha256"]
    output         = "${local.artifacts_directory}/checksum.{{ .ChecksumType }}"
  }
}
