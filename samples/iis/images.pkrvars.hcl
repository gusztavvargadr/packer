images = {
  "windows-server" = {
    core = {
      image_name        = "iis-windows-server"
      image_description = "IIS on Windows Server"
      image_version     = "2102.0"
    }

    native = {
      source_image_type = "windows-server"
      source_image_name = "2022-standard"
    }

    vagrant = {
      ports = "3389,80,443"
    }
  }

  "windows-server-core" = {
    core = {
      image_name        = "iis-windows-server-core"
      image_description = "SIIS on Windows Server Core"
      image_version     = "2102.0"
    }

    native = {
      source_image_type = "windows-server"
      source_image_name = "2022-standard-core"
    }

    vagrant = {
      ports = "3389,80,443"
    }
  }
}
