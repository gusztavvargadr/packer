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

  "2204" = {
    core = {
      image_description = "Kitchen on Ubuntu 22.04"
    }

    native = {
      source_image = "ubuntu-server/2204-lts"
      chef_keep    = "true"
    }
  }
}
