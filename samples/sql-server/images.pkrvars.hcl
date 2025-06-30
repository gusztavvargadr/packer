images = {
  "2019-developer-windows-server" = {
    core = {
      image_description = "SQL Server 2019 Developer on Windows Server"
    }

    native = {
      source_image = "windows-server/2022-standard"

      chef_attributes = "management-studio"
    }

    vagrant = {
      ports     = "3389,1433"
      box_alias = "sql-server"
    }
  }

  "2019-developer-windows-server-core" = {
    core = {
      image_description = "SQL Server 2019 Developer on Windows Server Core"
    }

    native = {
      source_image = "windows-server/2022-standard-core"
    }

    vagrant = {
      ports = "3389,1433"
    }
  }
}
