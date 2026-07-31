images = {
  "2404-lts-ubuntu" = {
    core = {
      image_description = "Ubuntu Desktop 24.04 LTS"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.4-desktop-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/24.04/ubuntu-24.04.4-desktop-amd64.iso"
      source_iso_checksum   = "sha256:3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e"

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

  "2404-lts-ubuntu-arm" = {
    core = {
      image_description = "Ubuntu Desktop 24.04 LTS"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.4-desktop-arm64.iso"
      source_iso_url_remote = "https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04.4-desktop-arm64.iso"
      source_iso_checksum   = "sha256:c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe"

      chef_attributes = "ubuntu"
    }

    vagrant = {
      memory       = "4096"
      ports        = "3389"
      box_name     = "ubuntu-desktop-2404-lts"
      box_alias    = "ubuntu-desktop"
      architecture = "arm64"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "arm-ubuntu-64"
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

  "2404-lts-xubuntu-arm" = {
    core = {
      image_description = "Xubuntu Desktop 24.04 LTS"
    }

    native = {
      source_image = "ubuntu-server/2404-lts-arm"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory       = "4096"
      ports        = "3389"
      box_name     = "xubuntu-desktop-2404-lts"
      box_alias    = "xubuntu-desktop"
      architecture = "arm64"
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

  "2204-lts-ubuntu-arm" = {
    core = {
      image_description = "Ubuntu Desktop 22.04 LTS"
    }

    native = {
      source_image = "ubuntu-server/2204-lts-arm"

      chef_attributes = "ubuntu"
    }

    vagrant = {
      memory       = "4096"
      ports        = "3389"
      box_name     = "ubuntu-desktop-2204-lts"
      architecture = "arm64"
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

  "2204-lts-xubuntu-arm" = {
    core = {
      image_description = "Xubuntu Desktop 22.04 LTS"
    }

    native = {
      source_image = "ubuntu-server/2204-lts-arm"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory       = "4096"
      ports        = "3389"
      box_name     = "xubuntu-desktop-2204-lts"
      architecture = "arm64"
    }
  }
}
