images = {
  "2404" = {
    core = {
      image_description = "Kitchen on Ubuntu 24.04"
    }

    native = {
      source_image = "ubuntu-server/2404-lts"
      chef_keep    = "true"
    }

    amazon = {
      source_ami_name = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    }
  }

  "2204" = {
    core = {
      image_description = "Kitchen on Ubuntu 22.04"
    }

    native = {
      source_image = "ubuntu-server/2204-lts"
      chef_keep    = "true"
    }

    amazon = {
      source_ami_name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
    }
  }
}
