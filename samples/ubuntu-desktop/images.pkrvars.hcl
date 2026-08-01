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

  "2404-lts-xubuntu-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Xubuntu Desktop 24.04 LTS ARM64"
    }

    native = {
      source_image = "ubuntu-server/2404-lts-arm64"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory    = "4096"
      ports     = "3389"
      box_name  = "xubuntu-desktop-2404-lts"
      box_alias = "xubuntu-desktop"
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
      memory   = "4096"
      ports    = "3389"
      box_name = "ubuntu-desktop-2204-lts"
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

  "2204-lts-xubuntu-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Xubuntu Desktop 22.04 LTS ARM64"
    }

    native = {
      source_image = "ubuntu-server/2204-lts-arm64"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory   = "4096"
      ports    = "3389"
      box_name = "xubuntu-desktop-2204-lts"
    }
  }
}
