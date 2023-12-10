images = {
  "2022-community-windows-11" = {
    core = {
      image_name        = "visual-studio/2022-community-windows-11"
      image_description = "Visual Studio 2022 Community on Windows 11"
      image_version     = "2022.2302"
    }

    native = {
      source_image = "windows-11/23h2-enterprise"

      chef_attributes = "2022-community"
    }

    vagrant = {
      cpus   = "4"
      memory = "8192"
    }
  }

  "2022-community-windows-10" = {
    core = {
      image_name        = "visual-studio/2022-community-windows-10"
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

  "2019-community-windows-11" = {
    core = {
      image_name        = "visual-studio/2019-community-windows-11"
      image_description = "Visual Studio 2019 Community on Windows 11"
      image_version     = "2019.2302"
    }

    native = {
      source_image = "windows-11/23h2-enterprise"

      chef_attributes = "2019-community"
    }

    vagrant = {
      cpus   = "4"
      memory = "8192"
    }
  }

  "2019-community-windows-10" = {
    core = {
      image_name        = "visual-studio/2019-community-windows-10"
      image_description = "Visual Studio 2019 Community on Windows 10"
      image_version     = "2019.2202"
    }

    native = {
      source_image = "windows-10/22h2-enterprise"

      chef_attributes = "2019-community"
    }

    vagrant = {
      cpus   = "4"
      memory = "8192"
    }
  }
}
