images = {
  "2404" = {
    core = {
      image_description = "Test Kitchen target for ubuntu-2404"
    }

    native = {
      source_image = "ubuntu-server/2404-lts"
      chef_keep    = "true"
    }

    vagrant = {
      box_alias = "kitchen-ubuntu"
    }
  }

  "2204" = {
    core = {
      image_description = "Test Kitchen target for ubuntu-2204"
    }

    native = {
      source_image = "ubuntu-server/2204-lts"
      chef_keep    = "true"
    }
  }
}
