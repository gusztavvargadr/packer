locals {
  timestamp = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"

  source_options_core = {
    vm_name          = "packer-${local.timestamp}"
    headless         = true
    output_directory = "${local.artifacts_directory}/image"

    cpus      = 4
    memory    = 8192
    disk_size = 130048

    boot_wait        = "1s"
    shutdown_timeout = "10m"
  }

  communicator = {
    type     = "ssh"
    username = "Administrator"
    password = "Packer42-"
    timeout  = "30m"
  }

  native_build  = local.image_build == "native"
  vagrant_build = local.image_build == "vagrant"
}

locals {
  source_options_build = merge(local.source_options_core, local.native_build ? local.source_options_native : local.source_options_vagrant)
}

source "null" "core" {
  communicator = "none"
}
