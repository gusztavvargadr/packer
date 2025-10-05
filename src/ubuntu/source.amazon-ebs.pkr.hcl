packer {
  required_plugins {
    amazon = {
      version = "~> 1.3.9"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "core" {
  ami_name = local.vm_name

  spot_price          = "auto"
  spot_instance_types = ["t3.xlarge"]

  ebs_optimized = true

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = "31"
    volume_type           = "gp3"
    delete_on_termination = true
  }

  source_ami_filter {
    filters = {
      // name                = "Windows_Server-2022-English-Full-Base-*"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }

    owners = ["amazon"]

    most_recent = true
  }

  // user_data = "<powershell>\r\n${file("${path.root}/boot/autounattend-first-logon.ps1")}\r\n</powershell>"

  tags = {
    "Name"   = local.vm_name
    "packer" = ""
  }

  run_tags = {
    "Name"   = local.vm_name
    "packer" = ""
  }

  spot_tags = {
    "Name"   = local.vm_name
    "packer" = ""
  }

  communicator = local.communicator.type
  ssh_username = local.communicator.username
  ssh_password = local.communicator.password
  ssh_timeout  = local.communicator.timeout
}
