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
    qemu       = "qemu.import"
  }

  native_iso          = contains(keys(local.image_options.native), "source_iso_checksum")
  downloads_directory = "${coalesce(var.userprofile_directory, var.home_directory)}/Downloads"

  native_unattended_options = {
    architecture = local.image_architecture
    boot         = local.image_options.native
    provider     = lookup(local.image_options, local.image_provider, {})
  }

  source_options_native = {
    iso_urls = local.native_iso ? [
      "${local.downloads_directory}/${local.image_options.native.source_iso_url_local}",
      local.image_options.native.source_iso_url_remote
    ] : []
    iso_checksum = local.native_iso ? local.image_options.native.source_iso_checksum : ""
    cd_content = merge({
      "autounattend.xml"             = templatefile("${path.root}/boot/autounattend.xml", local.native_unattended_options)
      "autounattend-first-logon.ps1" = templatefile("${path.root}/boot/autounattend-first-logon.ps1", local.native_unattended_options)
      }, {
      for setup_script in compact([lookup(local.image_options.native, "boot_setup_script", "")]) : setup_script => file("${path.cwd}/${setup_script}")
    })

    import_directory = local.native_build ? "${path.cwd}/../../artifacts/${lookup(local.image_options.native, "source_image", "")}/${local.image_provider}/native" : ""

    boot_command = local.native_iso ? [
      "<enter><wait><enter><wait><enter>"
    ] : []
    shutdown_command = "shutdown /s /t 10"
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

  provisioner "shell-local" {
    inline = local.vmware_boot_drivers_enabled ? [
      "mkdir -p \"${local.vmware_boot_drivers_directory}\"",
      "unzip -jo \"${local.vmware_boot_drivers_archive}\" \"vmxnet3/Win10_1709/ARM64/vmxnet3.cat\" \"vmxnet3/Win10_1709/ARM64/vmxnet3.inf\" \"vmxnet3/Win10_1709/ARM64/vmxnet3.sys\" -d \"${local.vmware_boot_drivers_directory}\"",
    ] : ["echo VMware boot drivers not required"]
  }
}

locals {
  chef_destination = "C:/Windows/Temp/chef/"
  chef_max_retries = 10
  chef_attributes  = lookup(local.image_options.native, "chef_attributes", "")
  chef_keep        = lookup(local.image_options.native, "chef_keep", "false")

  native_vmware_options       = lookup(local.image_options, "vmware", {})
  native_vmware_tools_source  = lookup(local.native_vmware_options, "tools_source", "")
  native_vmware_tools_version = lookup(local.native_vmware_options, "tools_version", "")

  native_virtualbox_options                   = lookup(local.image_options, "virtualbox", {})
  native_virtualbox_guest_additions_reconcile = local.image_provider == "virtualbox" ? lookup(local.native_virtualbox_options, "guest_additions_reconcile", "false") : "false"

  native_chef_environment = {
    CHEF_ATTRIBUTES                      = local.chef_attributes
    VIRTUALBOX_GUEST_ADDITIONS_RECONCILE = local.native_virtualbox_guest_additions_reconcile
    VMWARE_TOOLS_SOURCE                  = local.native_vmware_tools_source
    VMWARE_TOOLS_VERSION                 = local.native_vmware_tools_version
  }
}

build {
  name = "native-build"

  sources = local.native_build ? (local.native_iso ? compact([lookup(local.native_iso_sources, local.image_provider, "")]) : compact([lookup(local.native_import_sources, local.image_provider, "")])) : ["null.core"]

  provisioner "powershell" {
    script       = "${path.root}/chef/initialize.ps1"
    pause_before = "15s"

    elevated_user     = local.communicator.username
    elevated_password = local.communicator.password
  }

  provisioner "file" {
    source      = "${local.artifacts_directory}/chef/"
    destination = local.chef_destination
  }

  provisioner "file" {
    sources     = fileset(path.cwd, "attributes.*.json")
    destination = local.chef_destination
  }

  provisioner "powershell" {
    script           = "${path.root}/chef/apply.ps1"
    valid_exit_codes = [0, 35]

    env = local.native_chef_environment

    elevated_user     = local.communicator.username
    elevated_password = local.communicator.password
  }

  provisioner "powershell" {
    inline           = ["shutdown /r /t 60"]
    valid_exit_codes = [0, 1190]

    elevated_user     = local.communicator.username
    elevated_password = local.communicator.password
  }

  provisioner "powershell" {
    script       = "${path.root}/chef/apply.ps1"
    max_retries  = local.chef_max_retries
    pause_before = "300s"

    env = local.native_chef_environment

    elevated_user     = local.communicator.username
    elevated_password = local.communicator.password
  }

  provisioner "powershell" {
    script = "${path.root}/chef/cleanup.ps1"

    env = {
      CHEF_KEEP = local.chef_keep
    }

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

build {
  name = "native-test"

  sources = ["null.core"]
}

build {
  name = "native-publish"

  sources = ["null.core"]
}
