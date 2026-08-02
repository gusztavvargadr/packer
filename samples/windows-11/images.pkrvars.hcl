images = {
  "25h2-enterprise" = {
    core = {
      image_description = "Windows 11 Version 25H2 Enterprise"
    }

    native = {
      source_iso_url_local  = "26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26200.6584.250915-1905.25h2_ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:a61adeab895ef5a4db436e0a7011c92a2ff17bb0357f58b13bbc4062e535e7b9"

      boot_setup_script = "setup.cmd"
    }

    vagrant = {
      memory    = "4096"
      box_alias = "windows-11"
    }

    virtualbox = {
      guest_os_type = "Windows11_64"
    }

    vmware = {
      guest_os_type = "windows11-64"
    }
  }

  "25h2-professional-arm64" = {
    core = {
      architecture      = "arm64"
      image_description = "Windows 11 Version 25H2 Professional ARM64"
    }

    native = {
      source_iso_url_local  = "Win11_25H2_English_Arm64_v2.iso"
      source_iso_url_remote = ""
      source_iso_checksum   = "sha256:638aa2c88e94385b00f4f178d071e3df0b7d9e335577a83bd533b7f2eb65adf0"

      boot_setup_script = "setup.cmd"
      boot_image_name   = "Windows 11 Pro"
    }

    vagrant = {
      memory                     = "4096"
      box_alias                  = "windows-11"
      box_name                   = "windows-11-25h2-professional"
      default_architecture       = "arm64"
      alias_default_architecture = "amd64"
    }

    virtualbox = {
      audio_controller          = "none"
      chipset                   = "armv8virtual"
      guest_additions_reconcile = "true"
      guest_os_type             = "Windows11_arm64"
      iso_interface             = "sata"
      keyboard                  = "usb"
      mouse                     = "usbtablet"
      nic_type                  = "usbnet"
      usb                       = "true"
      usb_controller            = "xhci"
    }

    vmware = {
      boot_driver_archive           = "Contents/Library/isoimages/arm64/drivers-arm64.zip"
      boot_driver_drive             = "E:"
      guest_os_type                 = "arm-windows11-64"
      network_adapter_pcislotnumber = "160"
      network_adapter_type          = "vmxnet3"
      tools_source                  = "https://packages-prod.broadcom.com/tools/releases/13.1.0/windows/arm/VMware-tools-13.1.0-25218885-arm.exe"
      tools_version                 = "13.1.0"
    }
  }

  "24h2-enterprise" = {
    core = {
      image_description = "Windows 11 Version 24H2 Enterprise"
    }

    native = {
      source_iso_url_local  = "26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:755a90d43e826a74b9e1932a34788b898e028272439b777e5593dee8d53622ae"

      boot_setup_script = "setup.cmd"
    }

    vagrant = {
      memory = "4096"
    }

    virtualbox = {
      guest_os_type = "Windows11_64"
    }

    vmware = {
      guest_os_type = "windows11-64"
    }
  }

  "23h2-enterprise" = {
    core = {
      image_description = "Windows 11 Version 23H2 Enterprise"
    }

    native = {
      source_iso_url_local  = "22631.2428.231001-0608.23H2_NI_RELEASE_SVC_REFRESH_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/22631.2428.231001-0608.23H2_NI_RELEASE_SVC_REFRESH_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:c8dbc96b61d04c8b01faf6ce0794fdf33965c7b350eaa3eb1e6697019902945c"

      boot_setup_script = "setup.cmd"
    }

    vagrant = {
      memory = "4096"
    }

    virtualbox = {
      guest_os_type = "Windows11_64"
    }

    vmware = {
      guest_os_type = "windows11-64"
    }
  }

  "insider-preview-enterprise" = {
    core = {
      image_description = "Windows 11 Insider Preview Enterprise"
    }

    native = {
      source_iso_url_local  = "Windows11_InsiderPreview_EnterpriseVL_x64_en-us_29617_1000.iso"
      source_iso_url_remote = ""
      source_iso_checksum   = "sha256:403213b4a69f03e9bd595cedb57b9a51ac4248f434e71ccf9d445679a7cf92a5"

      boot_setup_script = "setup.cmd"
      boot_image_name   = "Windows 11 Enterprise"
    }

    vagrant = {
      memory = "4096"
    }

    virtualbox = {
      guest_os_type = "Windows11_64"
    }

    vmware = {
      guest_os_type = "windows11-64"
    }
  }
}
