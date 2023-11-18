images = {
  "community-windows-server" = {
    core = {
      image_name        = "docker-community-windows-server"
      image_description = "Docker Community on Windows Server"
      image_version     = "2400.2102"
    }

    native = {
      source_image_type = "windows-server"
      source_image_name = "2022-standard"
    }
  }

  "community-windows-server-core" = {
    core = {
      image_name        = "docker-community-windows-server-core"
      image_description = "Docker Community on Windows Server Core"
      image_version     = "2400.2102"
    }

    native = {
      source_image_type = "windows-server"
      source_image_name = "2022-standard-core"
    }
  }
}
