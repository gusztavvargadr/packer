packer {
  required_version = "~> 1.7.8"

  required_plugins {
    virtualbox = {
      version = "~> 1.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }

    hyperv = {
      version = "~> 1.0.1"
      source  = "github.com/hashicorp/hyperv"
    }
  }
}
