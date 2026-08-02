images = {
  "2404" = {
    core = {
      image_description = "Kitchen on Ubuntu 24.04"
    }

    native = {
      source_image = "ubuntu-server/2404-lts"
      chef_keep    = "true"
    }
  }

  "2404-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Kitchen on Ubuntu 24.04 ARM64"
    }

    native = {
      source_image = "ubuntu-server/2404-lts-arm64"
      chef_keep    = "true"
    }

    vagrant = {
      box_name = "kitchen-ubuntu-2404"
    }
  }

  "2204" = {
    core = {
      image_description = "Kitchen on Ubuntu 22.04"
    }

    native = {
      source_image = "ubuntu-server/2204-lts"
      chef_keep    = "true"
    }
  }

  "2204-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Kitchen on Ubuntu 22.04 ARM64"
    }

    native = {
      source_image = "ubuntu-server/2204-lts-arm64"
      chef_keep    = "true"
    }

    vagrant = {
      box_name = "kitchen-ubuntu-2204"
    }
  }
}
