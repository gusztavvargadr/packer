images = {
  "2204-lts" = {
    core = {
      name        = "u2204d"
      description = "Ubuntu Desktop 22.04 LTS"

      import_directory = "ubuntu-server"
      import_image     = "u2204s"
    }

    vagrant = {
      memory = "4096"
      ports = "3389"
    }
  }

  "2004-lts" = {
    core = {
      name        = "u2004d"
      description = "Ubuntu Desktop 20.04 LTS"

      import_directory = "ubuntu-server"
      import_image     = "u2004s"
    }

    vagrant = {
      memory = "4096"
      ports = "3389"
    }
  }
}
