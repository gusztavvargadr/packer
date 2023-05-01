packer {
  required_version = "~> 1.8.0"

  required_plugins {
    virtualbox = {
      version = "~> 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }

    hyperv = {
      version = "~> 1.0.0"
      source  = "github.com/hashicorp/hyperv"
    }

    vmware = {
      version = "~> 1.0.0"
      source  = "github.com/hashicorp/vmware"
    }

    vagrant = {
      version = "~> 1.0.0"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}
