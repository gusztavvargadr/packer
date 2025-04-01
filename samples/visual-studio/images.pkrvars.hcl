images = {
  "2022-community-windows-11" = {
    core = {
      image_description = "Visual Studio 2022 Community on Windows 11"
      image_version     = "2022.2402"
    }

    native = {
      source_image = "windows-11/24h2-enterprise"

      chef_attributes = "2022-community"
    }

    vagrant = {
      cpus      = "4"
      memory    = "8192"
      box_alias = "visual-studio"
    }
  }

  "2022-community-windows-10" = {
    core = {
      image_description = "Visual Studio 2022 Community on Windows 10"
      image_version     = "2022.2202"
    }

    native = {
      source_image = "windows-10/22h2-enterprise"

      chef_attributes = "2022-community"
    }

    vagrant = {
      cpus   = "4"
      memory = "8192"
    }
  }
}
