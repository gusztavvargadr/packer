images = {
  "community-ubuntu-server" = {
    core = {
      image_description = "Docker on Ubuntu 24.04"
      image_version     = "2600.2404"
    }

    native = {
      source_image = "ubuntu-server/2404-lts"
    }

    vagrant = {
      box_name  = "docker-community-ubuntu-server"
      box_alias = "docker-linux"
    }
  }
}
