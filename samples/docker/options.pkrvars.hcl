options = {
  "community-windows-server" = {
    name        = "ws2022s-dc"
    description = "Docker Community on Windows Server"

    parent_type = "windows-server"
    parent_configuration = "ws2022s"
  }

  "community-windows-server-core" = {
    name        = "ws2022sc-dc"
    description = "Docker Community on Windows Server Core"

    parent_type = "windows-server"
    parent_configuration = "ws2022sc"
  }
}
