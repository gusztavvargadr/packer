images = {
  "community-ubuntu-server" = {
    core = {
      image_description = "Docker on Ubuntu 24.04"
    }

    native = {
      source_image = "ubuntu-server/2404-lts"
    }

    vagrant = {
      box_name  = "docker-community-ubuntu-server"
      box_alias = "docker-linux"
    }
  }

  "community-ubuntu-server-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Docker on Ubuntu 24.04 ARM64"
    }

    native = {
      source_image = "ubuntu-server/2404-lts-arm64"
    }

    vagrant = {
      box_name  = "docker-community-ubuntu-server"
      box_alias = "docker-linux"
    }
  }
}
