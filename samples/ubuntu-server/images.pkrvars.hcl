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

  "2404-lts-arm" = {
    core = {
      image_description = "Ubuntu Server 24.04 LTS"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.3-live-server-arm64.iso"
      source_iso_url_remote = "https://cdimage.ubuntu.com/releases/24.04/release/ubuntu-24.04.3-live-server-arm64.iso"
      source_iso_checksum   = "sha256:2ee2163c9b901ff5926400e80759088ff3b879982a3956c02100495b489fd555"
    }

    vagrant = {
      box_alias    = "ubuntu-server"
      box_name     = "ubuntu-server-2404-lts"
      architecture = "arm64"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "arm-ubuntu-64"
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

  "2204-lts-arm" = {
    core = {
      image_description = "Ubuntu Server 22.04 LTS"
    }

    native = {
      source_iso_url_local  = "ubuntu-22.04.5-live-server-arm64.iso"
      source_iso_url_remote = "https://cdimage.ubuntu.com/releases/22.04/release/ubuntu-22.04.5-live-server-arm64.iso"
      source_iso_checksum   = "sha256:eafec62cfe760c30cac43f446463e628fada468c2de2f14e0e2bc27295187505"
    }

    vagrant = {
      box_name     = "ubuntu-server-2204-lts"
      architecture = "arm64"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "arm-ubuntu-64"
    }
  }
}
