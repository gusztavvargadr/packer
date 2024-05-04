images = {
  "2204" = {
    core = {
      image_description = "Test Kitchen target for ubuntu-2204"
      image_version     = "2204.0"
    }

    native = {
      source_image = "ubuntu-server/2204-lts"
      chef_keep    = "true"
    }
  }
}
