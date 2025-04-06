images = {
  "2025" = {
    core = {
      image_description = "Test Kitchen target for windows-2025"
      image_version     = "2402.0"
    }

    native = {
      source_image = "windows-server/2025-standard"
      chef_keep    = "true"
    }
  }

  "2022" = {
    core = {
      image_description = "Test Kitchen target for windows-2022"
      image_version     = "2102.0"
    }

    native = {
      source_image = "windows-server/2022-standard"
      chef_keep    = "true"
    }
  }
}
