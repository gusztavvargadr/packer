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

  "2404-arm" = {
    core = {
      image_description = "Test Kitchen target for ubuntu-2404"
    }

    native = {
      source_image = "ubuntu-server/2404-lts-arm"
      chef_keep    = "true"
    }

    vagrant = {
      box_alias = "kitchen-ubuntu"
      box_name     = "kitchen-ubuntu-2404"
      architecture = "arm64"
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

  "2204-arm" = {
    core = {
      image_description = "Test Kitchen target for ubuntu-2204"
    }

    native = {
      source_image = "ubuntu-server/2204-lts-arm"
      chef_keep    = "true"
    }

    vagrant = {
      box_name     = "kitchen-ubuntu-2204"
      architecture = "arm64"
    }
  }
}
