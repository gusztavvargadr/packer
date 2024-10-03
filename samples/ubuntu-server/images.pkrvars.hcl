images = {
  "2404-lts" = {
    core = {
      image_description = "Ubuntu Server 24.04 LTS"
      image_version     = "2404.0"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.1-live-server-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/noble/ubuntu-24.04.1-live-server-amd64.iso"
      source_iso_checksum   = "sha256:e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
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
      source_iso_url_local  = "ubuntu-20.04.5-live-server-amd64.iso"
      source_iso_url_remote = "https://old-releases.ubuntu.com/releases/focal/ubuntu-20.04.5-live-server-amd64.iso"
      source_iso_checksum   = "sha256:5035be37a7e9abbdc09f0d257f3e33416c1a0fb322ba860d42d74aa75c3468d4"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }
}
