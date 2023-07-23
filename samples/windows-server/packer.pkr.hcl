packer {
  required_version = "~> 1.9"

  required_plugins {
    virtualbox = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/virtualbox"
    }

    vmware = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/vmware"
    }

    hyperv = {
      version = "~> 1.1"
      source  = "github.com/hashicorp/hyperv"
    }

    vagrant = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}
