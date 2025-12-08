packer {
  required_plugins {
    amazon = {
      version = "~> 1.3.9"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  amazon_source_options = {
    region = "eu-west-1"

    spot_price          = "auto"
    spot_instance_types = ["c7i.xlarge"]

    ebs_optimized              = true
    disk_device_name           = "/dev/sda1"
    disk_size                  = "63"
    disk_type                  = "gp3"
    disk_delete_on_termination = true

    source_ami_name  = ""
    source_ami_owner = "amazon"

    user_data_file = "${path.root}/boot/autounattend-first-logon.amazon.ps1"

    communicator = {
      type     = local.communicator.type
      username = local.communicator.username
      password = local.communicator.password
      timeout  = local.communicator.timeout
    }

    tags = {
      "Name"    = local.source_options_build.vm_name
      "Service" = "${replace(local.image_name, "/", "-")}"
      "Stack"   = "gusztavvargadr-packer"
    }
  }
}

locals {
  amazon_ebs_source_options = merge(local.source_options_build, local.amazon_source_options, lookup(local.image_options, "amazon", {}))
}

source "amazon-ebs" "core" {
  region   = local.amazon_ebs_source_options.region
  ami_name = local.amazon_ebs_source_options.vm_name

  spot_price          = local.amazon_ebs_source_options.spot_price
  spot_instance_types = local.amazon_ebs_source_options.spot_instance_types

  ebs_optimized = local.amazon_ebs_source_options.ebs_optimized

  launch_block_device_mappings {
    device_name           = local.amazon_ebs_source_options.disk_device_name
    volume_size           = local.amazon_ebs_source_options.disk_size
    volume_type           = local.amazon_ebs_source_options.disk_type
    delete_on_termination = local.amazon_ebs_source_options.disk_delete_on_termination
  }

  source_ami_filter {
    filters = {
      name = local.amazon_ebs_source_options.source_ami_name
    }

    owners = [local.amazon_ebs_source_options.source_ami_owner]

    most_recent = true
  }

  user_data_file = local.amazon_ebs_source_options.user_data_file

  run_tags        = local.amazon_ebs_source_options.tags
  run_volume_tags = local.amazon_ebs_source_options.tags

  communicator = local.amazon_ebs_source_options.communicator.type
  ssh_username = local.amazon_ebs_source_options.communicator.username
  ssh_timeout  = local.amazon_ebs_source_options.communicator.timeout
}
