images = {
  "community-windows-server" = {
    core = {
      image_description = "Docker Community on Windows Server"
      image_version     = "2600.2402"
    }

    native = {
      source_image = "windows-server/2025-standard"
    }

    vagrant = {
      box_name  = "docker-community-windows-server"
      box_alias = "docker-windows"
    }
  }

  "community-windows-server-core" = {
    core = {
      image_description = "Docker Community on Windows Server Core"
      image_version     = "2600.2402"
    }

    native = {
      source_image = "windows-server/2025-standard-core"
    }

    vagrant = {
      box_name = "docker-community-windows-server-core"
    }
  }
}
