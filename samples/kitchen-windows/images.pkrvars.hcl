images = {
  "2025" = {
    core = {
      image_description = "Kitchen on Windows 2025"
    }

    native = {
      source_image = "windows-server/2025-standard"
      chef_keep    = "true"
    }

    amazon = {
      source_ami_name = "Windows_Server-2025-English-Full-Base-*"
    }
  }

  "2022" = {
    core = {
      image_description = "Kitchen on Windows 2022"
    }

    native = {
      source_image = "windows-server/2022-standard"
      chef_keep    = "true"
    }

    amazon = {
      source_ami_name = "Windows_Server-2022-English-Full-Base-*"
    }
  }
}
