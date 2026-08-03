images = {
  "2404-lts-ubuntu" = {
    core = {
      image_description = "Ubuntu Desktop 24.04 LTS"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.4-desktop-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/24.04/ubuntu-24.04.4-desktop-amd64.iso"
      source_iso_checksum   = "sha256:3a4c9877b483ab46d7c3fbe165a0db275e1ae3cfe56a5657e5a47c2f99a99d1e"

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

  "2404-lts-ubuntu-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Ubuntu Desktop 24.04 LTS ARM64"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.4-desktop-arm64.iso"
      source_iso_url_remote = "https://cdimage.ubuntu.com/ubuntu/releases/24.04/release/ubuntu-24.04.4-desktop-arm64.iso"
      source_iso_checksum   = "sha256:c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe"

      chef_attributes = "ubuntu"
    }

    vagrant = {
      memory    = "4096"
      ports     = "3389"
      box_name  = "ubuntu-desktop-2404-lts"
      box_alias = "ubuntu-desktop"
    }

    virtualbox = {
      audio_controller        = "none"
      boot_command_key_buffer = "true"
      boot_keygroup_interval  = "1s"
      boot_wait               = "10s"
      chipset                 = "armv8virtual"
      gfx_controller          = "qemuramfb"
      guest_os_type           = "Ubuntu24_LTS_arm64"
      iso_interface           = "sata"
      keyboard                = "usb"
      mouse                   = "usb"
      remove_ide_controller   = "true"
      usb                     = "true"
      usb_controller          = "xhci"
    }

    vmware = {
      cdrom_adapter_type   = "sata"
      disk_adapter_type    = "sata"
      guest_os_type        = "arm-ubuntu-64"
      network_adapter_type = "e1000e"
      vmx_svga_autodetect  = "TRUE"
      vmx_usb_xhci_present = "TRUE"
    }
  }

  "2404-lts-xubuntu" = {
    core = {
      image_description = "Xubuntu Desktop 24.04 LTS"
    }

    native = {
      source_image = "ubuntu-server/2404-lts"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory    = "4096"
      ports     = "3389"
      box_name  = "xubuntu-desktop-2404-lts"
      box_alias = "xubuntu-desktop"
    }

    virtualbox = {
      guest_os_type = "Ubuntu_64"
    }

    vmware = {
      guest_os_type = "ubuntu-64"
    }
  }

  "2404-lts-xubuntu-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Xubuntu Desktop 24.04 LTS ARM64"
    }

    native = {
      source_image = "ubuntu-server/2404-lts-arm64"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory    = "4096"
      ports     = "3389"
      box_name  = "xubuntu-desktop-2404-lts"
      box_alias = "xubuntu-desktop"
    }
  }

  "2204-lts-ubuntu" = {
    core = {
      image_description = "Ubuntu Desktop 22.04 LTS"
    }

    native = {
      source_image = "ubuntu-server/2204-lts"

      chef_attributes = "ubuntu"
    }

    vagrant = {
      memory   = "4096"
      ports    = "3389"
      box_name = "ubuntu-desktop-2204-lts"
    }
  }

  "2204-lts-ubuntu-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Ubuntu Desktop 22.04 LTS ARM64"
    }

    native = {
      source_image = "ubuntu-server/2204-lts-arm64"

      chef_attributes = "ubuntu"
    }

    vagrant = {
      memory   = "4096"
      ports    = "3389"
      box_name = "ubuntu-desktop-2204-lts"
    }
  }

  "2204-lts-xubuntu" = {
    core = {
      image_description = "Xubuntu Desktop 22.04 LTS"
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

  "2204-lts-xubuntu-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Xubuntu Desktop 22.04 LTS ARM64"
    }

    native = {
      source_image = "ubuntu-server/2204-lts-arm64"

      chef_attributes = "xubuntu"
    }

    vagrant = {
      memory   = "4096"
      ports    = "3389"
      box_name = "xubuntu-desktop-2204-lts"
    }
  }
}
