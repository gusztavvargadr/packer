images = {
  "2404-lts" = {
    core = {
      image_description = "Ubuntu Server 24.04 LTS"
      image_version     = "2404.0"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04-live-server-amd64.iso"
      source_iso_url_remote = "https://app.vagrantup.com/gusztavvargadr-iso/boxes/ubuntu-server/versions/2404.0.2404/providers/iso/amd64/vagrant.box"
      source_iso_checksum   = "sha256:8762f7e74e4d64d72fceb5f70682e6b069932deedb4949c6975d0f0fe0a91be3"
    }

    vagrant = {
      box_alias = "ubuntu-server"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }

  "2204-lts" = {
    core = {
      image_description = "Ubuntu Server 22.04 LTS"
      image_version     = "2204.0"
    }

    native = {
      source_iso_url_local  = "ubuntu-22.04.3-live-server-amd64.iso"
      source_iso_url_remote = "https://app.vagrantup.com/gusztavvargadr-iso/boxes/ubuntu-server/versions/2204.0.2404/providers/iso/amd64/vagrant.box"
      source_iso_checksum   = "sha256:a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }

  "2004-lts" = {
    core = {
      image_description = "Ubuntu Server 20.04 LTS"
      image_version     = "2004.0"
    }

    native = {
      source_iso_url_local  = "ubuntu-20.04.4-live-server-amd64.iso"
      source_iso_url_remote = "https://app.vagrantup.com/gusztavvargadr-iso/boxes/ubuntu-server/versions/2004.0.2404/providers/iso/amd64/vagrant.box"
      source_iso_checksum   = "sha256:28ccdb56450e643bad03bb7bcf7507ce3d8d90e8bf09e38f6bd9ac298a98eaad"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }
}
