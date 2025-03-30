images = {
  "2404-lts" = {
    core = {
      image_description = "Ubuntu Server 24.04 LTS"
      image_version     = "2404.0"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.2-live-server-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/noble/ubuntu-24.04.2-live-server-amd64.iso"
      source_iso_checksum   = "sha256:d6dab0c3a657988501b4bd76f1297c053df710e06e0c3aece60dead24f270b4d"
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
      source_iso_url_local  = "ubuntu-22.04.4-live-server-amd64.iso"
      source_iso_url_remote = "https://old-releases.ubuntu.com/releases/jammy/ubuntu-22.04.4-live-server-amd64.iso"
      source_iso_checksum   = "sha256:45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
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
      source_iso_url_remote = "https://old-releases.ubuntu.com/releases/focal/ubuntu-20.04.4-live-server-amd64.iso"
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
