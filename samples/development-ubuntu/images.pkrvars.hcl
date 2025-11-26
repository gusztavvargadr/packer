images = {
  "2404" = {
    core = {
      image_description = "Development on ubuntu-2404"
    }

    native = {
      source_image = "ubuntu-desktop/2404-lts-ubuntu"
    }

    vagrant = {
      cpus      = "4"
      memory    = "8192"
      box_alias = "development-ubuntu"
    }
  }

  "2204" = {
    core = {
      image_description = "Development on ubuntu-2204"
    }

    native = {
      source_image = "ubuntu-desktop/2204-lts-ubuntu"
    }

    vagrant = {
      cpus      = "4"
      memory    = "8192"
    }
  }
}
