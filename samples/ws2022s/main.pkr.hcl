variables {
  author      = "gusztavvargadr"
  name        = "ws2022sc"
  description = "Windows Server 2022 Standard Core"
  version     = "2112.0.0"

  download_directory = "${env("HOME")}/Downloads"
}

source "null" "chef" {
  communicator = "none"
}

build {
  source "null.chef" {
  }

  provisioner "shell-local" {
    inline = [
      "cd provisioners/chef",
      "chef install",
      "chef export policies --archive"
    ]
  }
}

build {
  source "hyperv-iso.default" {
    name             = "hyperv-core"
    output_directory = "output/${source.name}/image"
  }

  provisioner "file" {
    source      = "builders/iso/scripts"
    destination = "C:/Windows/Temp/packer"
  }

  provisioner "powershell" {
    script            = "provisioners/chef/scripts/prepare.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "file" {
    source      = "provisioners/chef/policies"
    destination = "C:/Windows/Temp/packer"
  }

  provisioner "powershell" {
    inline = [
      "cd C:/Windows/Temp/packer/policies",
      "7z x *.tgz",
      "7z x *.tar",
      "rm *.tar",
      "rm *.tgz"
    ]
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "powershell" {
    inline = [
      "cd C:/Windows/Temp/packer/policies",
      "chef-client --local-mode --named-run-list prepare"
    ]
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    inline = [
      "cd C:/Windows/Temp/packer/policies",
      "chef-client --local-mode --named-run-list install"
    ]
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    inline = [
      "cd C:/Windows/Temp/packer/policies",
      "chef-client --local-mode --named-run-list patch"
    ]
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    inline = [
      "cd C:/Windows/Temp/packer/policies",
      "chef-client --local-mode --named-run-list patch"
    ]
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    inline = [
      "cd C:/Windows/Temp/packer/policies",
      "chef-client --local-mode --named-run-list patch"
    ]
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    inline = [
      "cd C:/Windows/Temp/packer/policies",
      "chef-client --local-mode --named-run-list patch"
    ]
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    inline = [
      "cd C:/Windows/Temp/packer/policies",
      "chef-client --local-mode --named-run-list cleanup"
    ]
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  provisioner "powershell" {
    script            = "provisioners/chef/scripts/cleanup.ps1"
    elevated_user     = local.communicator_username
    elevated_password = local.communicator_password
  }

  post-processor "manifest" {
    output = "output/${source.name}/manifest.json"
  }

  post-processor "checksum" {
    checksum_types = ["sha256"]
    output         = "output/${source.name}/checksum.{{.ChecksumType}}"
  }
}
