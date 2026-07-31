images = {
  "2404-lts" = {
    core = {
      image_description = "Ubuntu Server 24.04 LTS"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.4-live-server-amd64.iso"
      source_iso_url_remote = "https://releases.ubuntu.com/24.04/ubuntu-24.04.4-live-server-amd64.iso"
      source_iso_checksum   = "sha256:e907d92eeec9df64163a7e454cbc8d7755e8ddc7ed42f99dbc80c40f1a138433"
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

  "2404-lts-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Ubuntu Server 24.04 LTS ARM64"
    }

    native = {
      source_iso_url_local  = "ubuntu-24.04.4-live-server-arm64.iso"
      source_iso_url_remote = "https://cdimage.ubuntu.com/ubuntu/releases/24.04/release/ubuntu-24.04.4-live-server-arm64.iso"
      source_iso_checksum   = "sha256:9a6ce6d7e66c8abed24d24944570a495caca80b3b0007df02818e13829f27f32"
    }

    vagrant = {
      box_alias = "ubuntu-server"
      box_name  = "ubuntu-server-2404-lts"
    }

    virtualbox = {
      audio_controller = "none"
      chipset          = "armv8virtual"
      gfx_controller   = "qemuramfb"
      guest_os_type    = "Ubuntu24_LTS_arm64"
      iso_interface    = "sata"
      keyboard         = "usb"
      mouse            = "usb"
      usb              = "true"
      usb_controller   = "xhci"
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

  "2204-lts-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Ubuntu Server 22.04 LTS ARM64"
    }

    native = {
      source_iso_url_local  = "ubuntu-22.04.5-live-server-arm64.iso"
      source_iso_url_remote = "https://cdimage.ubuntu.com/ubuntu/releases/22.04/release/ubuntu-22.04.5-live-server-arm64.iso"
      source_iso_checksum   = "sha256:eafec62cfe760c30cac43f446463e628fada468c2de2f14e0e2bc27295187505"
    }

    vagrant = {
      box_name = "ubuntu-server-2204-lts"
    }

    virtualbox = {
      audio_controller = "none"
      chipset          = "armv8virtual"
      gfx_controller   = "qemuramfb"
      guest_os_type    = "Ubuntu_arm64"
      iso_interface    = "sata"
      keyboard         = "usb"
      mouse            = "usb"
      usb              = "true"
      usb_controller   = "xhci"
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
