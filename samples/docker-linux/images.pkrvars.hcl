images = {
  "community-ubuntu-server" = {
    core = {
      image_name        = "docker-community/ubuntu-server"
      image_description = "Docker Community on Ubuntu Server"
      image_version     = "2400.2204"
    }

    native = {
      source_image = "ubuntu-server/2204-lts"
    }
  }
}
