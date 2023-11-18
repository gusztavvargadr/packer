locals {
  timestamp = "${formatdate("YYYYMMDD'-'hhmmss", timestamp())}"

  source_options_core = {
    vm_name          = "${local.timestamp}"
    headless         = true
    output_directory = "${local.artifacts_directory}/image"

    cpus      = 4
    memory    = 8192
    disk_size = 130048

    boot_wait        = "2s"
    shutdown_timeout = "5m"
  }

  communicator = {
    type     = "ssh"
    username = "vagrant"
    password = "vagrant"
    timeout  = "30m"
  }

  native_build  = var.build == "native"
  vagrant_build = var.build == "vagrant"
}

locals {
  source_options_build = merge(local.source_options_core, local.native_build ? local.source_options_native : local.source_options_vagrant)
}

source "null" "core" {
  communicator = "none"
}
