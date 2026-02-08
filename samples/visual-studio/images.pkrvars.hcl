images = {
  "2022-community-windows-11" = {
    core = {
      image_description = "Visual Studio 2022 Community on Windows 11"
    }

    native = {
      source_image = "windows-11/25h2-enterprise"

      chef_attributes = "2022-community"
    }

    vagrant = {
      cpus      = "4"
      memory    = "8192"
      box_alias = "visual-studio"
    }
  }
}
