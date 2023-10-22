images = {
  "community-windows-server" = {
    core = {
      name        = "ws2022s-dc"
      description = "Docker Community on Windows Server"

      import_directory = "windows-server"
      import_image     = "ws2022s"
    }
  }

  "community-windows-server-core" = {
    core = {
      name        = "ws2022sc-dc"
      description = "Docker Community on Windows Server Core"

      import_directory = "windows-server"
      import_image     = "ws2022sc"
    }
  }
}
