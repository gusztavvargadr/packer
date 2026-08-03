images = {
  "2404" = {
    core = {
      image_description = "Development on Ubuntu 24.04"
    }

    native = {
      source_image = "ubuntu-desktop/2404-lts-ubuntu"
    }

    vagrant = {
      cpus   = "4"
      memory = "8192"
    }
  }

  "2404-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Development on Ubuntu 24.04 ARM64"
    }

    native = {
      source_image = "ubuntu-desktop/2404-lts-ubuntu-arm64"
    }

    vagrant = {
      cpus     = "4"
      memory   = "8192"
      box_name = "development-ubuntu-2404"
    }
  }

  "2204" = {
    core = {
      image_description = "Development on Ubuntu 22.04"
    }

    native = {
      source_image = "ubuntu-desktop/2204-lts-ubuntu"
    }

    vagrant = {
      cpus   = "4"
      memory = "8192"
    }
  }

  "2204-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Development on Ubuntu 22.04 ARM64"
    }

    native = {
      source_image = "ubuntu-desktop/2204-lts-ubuntu-arm64"
    }

    vagrant = {
      cpus     = "4"
      memory   = "8192"
      box_name = "development-ubuntu-2204"
    }
  }
}
