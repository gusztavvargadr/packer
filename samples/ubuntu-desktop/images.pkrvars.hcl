images = {
  "2204-lts-ubuntu" = {
    core = {
      image_name        = "ubuntu-desktop/2204-lts-ubuntu"
      image_description = "Ubuntu Desktop 22.04 LTS"
      image_version     = "2204.0"
    }

    native = {
      source_image = "ubuntu-server/2204-lts"

      chef_attributes = "ubuntu"
    }

    vagrant = {
      memory    = "4096"
      ports     = "3389"
      box_name  = "ubuntu-desktop-2204-lts"
      box_alias = "ubuntu-desktop"
    }
  }

  "2204-lts-xubuntu" = {
    core = {
      image_name        = "ubuntu-desktop/2204-lts-xubuntu"
      image_description = "Xubuntu Desktop 22.04 LTS"
      image_version     = "2204.0"
    }

    native = {
      source_image = "ubuntu-server/2204-lts"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory   = "4096"
      ports    = "3389"
      box_name = "xubuntu-desktop-2204-lts"
    }
  }

  "2004-lts-ubuntu" = {
    core = {
      image_name        = "ubuntu-desktop/2004-lts-ubuntu"
      image_description = "Ubuntu Desktop 20.04 LTS"
      image_version     = "2004.0"
    }

    native = {
      source_image = "ubuntu-server/2004-lts"

      chef_attributes = "ubuntu"
    }

    vagrant = {
      memory   = "4096"
      ports    = "3389"
      box_name = "ubuntu-desktop-2004-lts"
    }
  }

  "2004-lts-xubuntu" = {
    core = {
      image_name        = "ubuntu-desktop/2004-lts-xubuntu"
      image_description = "Xubuntu Desktop 20.04 LTS"
      image_version     = "2004.0"
    }

    native = {
      source_image = "ubuntu-server/2004-lts"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory   = "4096"
      ports    = "3389"
      box_name = "ubuntu-desktop-2004-lts-xfce"
    }
  }
}
