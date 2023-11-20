images = {
  "2019-developer-windows-server" = {
    core = {
      image_name        = "sql-server-2019-developer-windows-server"
      image_description = "SQL Server 2019 Developer on Windows Server"
      image_version     = "2019.2102"
    }

    native = {
      source_image_type = "windows-server"
      source_image_name = "2022-standard"

      chef_attributes = "management-studio"
    }

    vagrant = {
      ports = "3389,1433"
    }
  }

  "2019-developer-windows-server-core" = {
    core = {
      image_name        = "sql-server-2019-developer-windows-server-core"
      image_description = "SQL Server 2019 Developer on Windows Server Core"
      image_version     = "2019.2102"
    }

    native = {
      source_image_type = "windows-server"
      source_image_name = "2022-standard-core"
    }

    vagrant = {
      ports = "3389,1433"
    }
  }
}
