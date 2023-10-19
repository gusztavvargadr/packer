packer {
  required_plugins {
    amazon = {
      version = "~> 1.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  amazon_user_data = "<powershell>\r\n${file("${path.root}/boot/autounattend-first-logon.ps1")}\r\n</powershell>"
}

source "amazon-ebs" "core" {
  ami_name = local.vm_name

  source_ami_filter {
    filters = {
      name                = "Windows_Server-2022-English-Full-Base-*"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }

    owners = ["amazon"]

    most_recent = true
  }

  tags = {
    "Name"   = local.vm_name
    "packer" = ""
  }

  spot_price          = "auto"
  spot_instance_types = ["t3.xlarge"]

  ebs_optimized = true

  run_tags = {
    "Name"   = local.vm_name
    "packer" = ""
  }

  spot_tags = {
    "Name"   = local.vm_name
    "packer" = ""
  }

  user_data = local.amazon_user_data

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "31"
    volume_type           = "gp3"
    delete_on_termination = true
  }

  communicator   = local.communicator_type
  ssh_username   = local.communicator_username
  ssh_password   = local.communicator_password
  ssh_timeout    = local.communicator_timeout
  winrm_username = local.communicator_username
  winrm_password = local.communicator_password
  winrm_timeout  = local.communicator_timeout
}
