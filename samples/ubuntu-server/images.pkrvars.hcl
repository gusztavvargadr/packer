images = {
  "2404-lts" = {
    core = {
      image_description = "Ubuntu Server 24.04 LTS"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.3-live-server-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/24.04/ubuntu-24.04.3-live-server-amd64.iso"
      source_iso_checksum   = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
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
}
