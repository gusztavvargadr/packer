images = {
  "community-ubuntu-server" = {
    core = {
      image_description = "Docker Community on Ubuntu Server"
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
