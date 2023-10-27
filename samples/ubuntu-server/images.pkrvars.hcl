images = {
  "2004-lts" = {
    core = {
      name        = "u2004s"
      description = "Ubuntu Server 20.04 LTS"

      iso_url_local  = "ubuntu-20.04.6-live-server-amd64.iso"
      iso_url_remote = "https://releases.ubuntu.com/20.04.6/ubuntu-20.04.6-live-server-amd64.iso"
      iso_checksum   = "sha256:b8f31413336b9393ad5d8ef0282717b2ab19f007df2e9ed5196c13d8f9153c8b"
    }

    virtualbox = {
      guest_os_type = "Windows2019_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }

  "2204-lts" = {
    core = {
      name        = "u2204s"
      description = "Ubuntu Server 22.04 LTS"

      iso_url_local  = "ubuntu-22.04.3-live-server-amd64.iso"
      iso_url_remote = "https://releases.ubuntu.com/22.04.3/ubuntu-22.04.3-live-server-amd64.iso"
      iso_checksum   = "sha256:a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
    }

    virtualbox = {
      guest_os_type = "Windows2019_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }
}
