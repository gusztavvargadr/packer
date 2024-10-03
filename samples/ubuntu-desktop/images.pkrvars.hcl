images = {
  "2404-lts-ubuntu" = {
    core = {
      image_name        = "ubuntu-desktop/2404-lts-ubuntu"
      image_description = "Ubuntu Desktop 24.04 LTS"
      image_version     = "2404.0"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.1-desktop-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/noble/ubuntu-24.04.1-desktop-amd64.iso"
      source_iso_checksum   = "sha256:c2e6f4dc37ac944e2ed507f87c6188dd4d3179bf4a3f9e110d3c88d1f3294bdc"

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
      image_name        = "ubuntu-desktop/2404-lts-xubuntu"
      image_description = "Xubuntu Desktop 24.04 LTS"
      image_version     = "2404.0"
    }

    native = {
      source_iso_url_local  = "xubuntu-24.04.1-desktop-amd64.iso"
      source_iso_url_remote = "https://cdimage.ubuntu.com/xubuntu/releases/noble/release/xubuntu-24.04.1-desktop-amd64.iso"
      source_iso_checksum   = "sha256:c333806173558ccc2a95f44c5c7b57437ee3d409b50a3a5a1367bcf7eaf3ef90"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory    = "4096"
      ports     = "3389"
      box_name  = "xubuntu-desktop-2404-lts"
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
