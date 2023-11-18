images = {
  "2204-lts-ubuntu" = {
    core = {
      image_name        = "ubuntu-desktop-2204-lts"
      image_description = "Ubuntu Desktop 22.04 LTS"
      image_version     = "2204"
    }

    native = {
      source_image_type = "ubuntu-server"
      source_image_name = "2204-lts"

      chef_attributes = "ubuntu"
    }

    vagrant = {
      memory = "4096"
      ports  = "3389"
    }
  }

  "2204-lts-xubuntu" = {
    core = {
      image_name        = "xubuntu-desktop-2204-lts"
      image_description = "Xubuntu Desktop 22.04 LTS"
      image_version     = "2204"
    }

    native = {
      source_image_type = "ubuntu-server"
      source_image_name = "2204-lts"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory = "4096"
      ports  = "3389"
    }
  }

  "2004-lts-ubuntu" = {
    core = {
      image_name        = "ubuntu-desktop-2004-lts"
      image_description = "Ubuntu Desktop 20.04 LTS"
      image_version     = "2004"
    }

    native = {
      source_image_type = "ubuntu-server"
      source_image_name = "2004-lts"

      chef_attributes = "ubuntu"
    }

    vagrant = {
      memory = "4096"
      ports  = "3389"
    }
  }

  "2004-lts-xubuntu" = {
    core = {
      image_name        = "ubuntu-desktop-2004-lts-xfce"
      image_description = "Xubuntu Desktop 20.04 LTS"
      image_version     = "2004"
    }

    native = {
      source_image_type = "ubuntu-server"
      source_image_name = "2004-lts"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory = "4096"
      ports  = "3389"
    }
  }
}
