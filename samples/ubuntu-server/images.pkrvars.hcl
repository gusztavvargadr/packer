images = {
  "2404-lts" = {
    core = {
      image_description = "Ubuntu Server 24.04 LTS"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.2-live-server-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/24.04/ubuntu-24.04.2-live-server-amd64.iso"
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
    }

    native = {
      source_iso_url_local  = "ubuntu-22.04.5-live-server-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
      source_iso_checksum   = "sha256:9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
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
    }

    native = {
      source_iso_url_local  = "ubuntu-20.04.6-live-server-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/20.04/ubuntu-20.04.6-live-server-amd64.iso"
      source_iso_checksum   = "sha256:b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }
}
