images = {
  "2404-lts-ubuntu" = {
    core = {
      image_name        = "ubuntu-desktop/2404-lts-ubuntu"
      image_description = "Ubuntu Desktop 24.04 LTS"
      image_version     = "2404.0"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04-desktop-amd64.iso"
      source_iso_url_remote = "https://api.hashicorp.cloud/vagrant/2022-08-01/gusztavvargadr-iso/boxes/ubuntu-desktop/versions/2404.0.2404/providers/iso/amd64/vagrant.box"
      source_iso_checksum   = "sha256:81fae9cc21e2b1e3a9a4526c7dad3131b668e346c580702235ad4d02645d9455"

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
      source_iso_url_local  = "xubuntu-24.04-desktop-amd64.iso"
      source_iso_url_remote = "https://api.hashicorp.cloud/vagrant/2022-08-01/gusztavvargadr-iso/boxes/xubuntu-desktop/versions/2404.0.2404/providers/iso/amd64/vagrant.box"
      source_iso_checksum   = "sha256:8c47b15c4089473bcc58e369a472cabf83d137c7bf8ad7d9465ad086e7bd5272"

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
