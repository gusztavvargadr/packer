images = {
  "2022" = {
    core = {
      image_description = "Test Kitchen target for windows-2022"
      image_version     = "2102.0"
    }

    native = {
      source_image = "windows-server/2022-standard-core"
      chef_keep    = "true"
    }
  }
}
