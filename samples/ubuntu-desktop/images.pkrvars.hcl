images = {
  "2404-lts-ubuntu" = {
    core = {
      image_description = "Ubuntu Desktop 24.04 LTS"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.3-desktop-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/24.04/ubuntu-24.04.3-desktop-amd64.iso"
      source_iso_checksum   = "sha256:faabcf33ae53976d2b8207a001ff32f4e5daae013505ac7188c9ea63988f8328"

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
}
