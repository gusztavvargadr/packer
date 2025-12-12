images = {
  "2025" = {
    core = {
      image_description = "Test Kitchen target for Windows 2025"
    }

    native = {
      source_image = "windows-server/2025-standard"
      chef_keep    = "true"
    }
  }

  "2022" = {
    core = {
      image_description = "Test Kitchen target for Windows 2022"
    }

    native = {
      source_image = "windows-server/2022-standard"
      chef_keep    = "true"
    }
  }
}
