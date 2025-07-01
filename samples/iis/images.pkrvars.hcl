images = {
  "windows-server" = {
    core = {
      image_description = "IIS on Windows Server"
    }

    native = {
      source_image = "windows-server/2022-standard"
    }

    vagrant = {
      ports     = "3389,80"
      box_alias = "iis"
    }
  }

  "windows-server-core" = {
    core = {
      image_description = "IIS on Windows Server Core"
    }

    native = {
      source_image = "windows-server/2022-standard-core"
    }

    vagrant = {
      ports = "3389,80"
    }
  }
}
