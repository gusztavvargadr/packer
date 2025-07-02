images = {
  "2404-lts-ubuntu" = {
    core = {
      image_description = "Ubuntu Desktop 24.04 LTS"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.2-desktop-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/24.04/ubuntu-24.04.2-desktop-amd64.iso"
      source_iso_checksum   = "sha256:d7fe3d6a0419667d2f8eff12796996328daa2d4f90cd9f87aa9371b362f987bf"

      chef_attributes = "ubuntu"
    }

    vagrant = {
      memory    = "4096"
      ports     = "3389"
      box_name  = "ubuntu-desktop-2404-lts"
      box_alias = "ubuntu-desktop"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }

  "2404-lts-xubuntu" = {
    core = {
      image_description = "Xubuntu Desktop 24.04 LTS"
    }

    native = {
      source_image = "ubuntu-server/2404-lts"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory    = "4096"
      ports     = "3389"
      box_name  = "xubuntu-desktop-2404-lts"
      box_alias = "xubuntu-desktop"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }

  "2204-lts-ubuntu" = {
    core = {
      image_description = "Ubuntu Desktop 22.04 LTS"
    }

    native = {
      source_image = "ubuntu-server/2204-lts"

      chef_attributes = "ubuntu"
    }

    vagrant = {
      memory    = "4096"
      ports     = "3389"
      box_name  = "ubuntu-desktop-2204-lts"
    }
  }

  "2204-lts-xubuntu" = {
    core = {
      image_description = "Xubuntu Desktop 22.04 LTS"
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
      image_description = "Ubuntu Desktop 20.04 LTS"
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
