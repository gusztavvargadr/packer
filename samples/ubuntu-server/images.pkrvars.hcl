images = {
  "2004-lts" = {
    core = {
      name        = "u2004s"
      description = "Ubuntu Server 20.04 LTS"

      iso_url_local  = "ubuntu-20.04.1-legacy-server-amd64.iso"
      iso_url_remote = "https://cdimage.ubuntu.com/ubuntu-legacy-server/releases/20.04/release/ubuntu-20.04.1-legacy-server-amd64.iso"
      iso_checksum   = "sha256:f11bda2f2caed8f420802b59f382c25160b114ccc665dbac9c5046e7fceaced2"
    }

    virtualbox = {
      guest_os_type = "Windows2019_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }
}
