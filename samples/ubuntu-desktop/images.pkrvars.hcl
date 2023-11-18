images = {
  "2204-lts" = {
    core = {
      image_name        = "ubuntu-desktop-2204-lts"
      image_description = "Ubuntu Desktop 22.04 LTS"
      image_version     = "2204"
    }

    native = {
      source_image_type = "ubuntu-server"
      source_image_name = "2204-lts"
    }

    vagrant = {
      memory = "4096"
      ports  = "3389"
    }
  }

  "2004-lts" = {
    core = {
      image_name        = "ubuntu-desktop-2004-lts"
      image_description = "Ubuntu Desktop 20.04 LTS"
      image_version     = "2004"
    }

    native = {
      source_image_type = "ubuntu-server"
      source_image_name = "2004-lts"
    }

    vagrant = {
      memory = "4096"
      ports  = "3389"
    }
  }
}
