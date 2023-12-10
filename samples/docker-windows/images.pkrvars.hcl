images = {
  "community-windows-server" = {
    core = {
      image_description = "Docker Community on Windows Server"
      image_version     = "2400.2102"
    }

    native = {
      source_image = "windows-server/2022-standard"
    }

    vagrant = {
      box_name = "docker-community-windows-server"
    }
  }

  "community-windows-server-core" = {
    core = {
      image_description = "Docker Community on Windows Server Core"
      image_version     = "2400.2102"
    }

    native = {
      source_image = "windows-server/2022-standard-core"
    }

    vagrant = {
      box_name = "docker-community-windows-server-core"
    }
  }
}
