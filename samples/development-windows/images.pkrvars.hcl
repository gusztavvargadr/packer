images = {
  "2025" = {
    core = {
      image_description = "Development on windows-2025"
    }

    native = {
      source_image = "windows-server/2025-standard"
    }

    vagrant = {
      memory    = "4096"
      box_alias = "development-windows"
    }
  }

  "2022" = {
    core = {
      image_description = "Development on windows-2022"
    }

    native = {
      source_image = "windows-server/2022-standard"
    }

    vagrant = {
      memory    = "4096"
    }
  }
}
