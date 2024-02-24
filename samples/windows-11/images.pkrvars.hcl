images = {
  "23h2-enterprise" = {
    core = {
      image_name        = "windows-11/23h2-enterprise"
      image_description = "Windows 11 Version 23H2 Enterprise"
      image_version     = "2302.0"
    }

    native = {
      source_iso_url_local  = "22631.2428.231001-0608.23H2_NI_RELEASE_SVC_REFRESH_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/22631.2428.231001-0608.23H2_NI_RELEASE_SVC_REFRESH_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:c8dbc96b61d04c8b01faf6ce0794fdf33965c7b350eaa3eb1e6697019902945c"

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

  "22h2-enterprise" = {
    core = {
      image_name        = "windows-11/22h2-enterprise"
      image_description = "Windows 11 Version 22H2 Enterprise"
      image_version     = "2202.0"
    }

    native = {
      source_iso_url_local  = "22621.525.220925-0207.ni_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66751/22621.525.220925-0207.ni_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:ebbc79106715f44f5020f77bd90721b17c5a877cbc15a3535b99155493a1bb3f"

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

  "21h2-enterprise" = {
    core = {
      image_name        = "windows-11/21h2-enterprise"
      image_description = "Windows 11 Version 21H2 Enterprise"
      image_version     = "2102.0"
    }

    native = {
      source_iso_url_local  = "22000.194.210913-1444.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-download.microsoft.com/download/sg/22000.194.210913-1444.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:e8b1d2a1a85a09b4bf6154084a8be8e3c814894a15a7bcf3e8e63fcfa9a528cb"

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
      image_name        = "windows-11/insider-preview-enterprise"
      image_description = "Windows 11 Insider Preview Enterprise"
      image_version     = "2302.0"
    }

    native = {
      source_iso_url_local  = "Windows11_InsiderPreview_EnterpriseVL_x64_en-us_26040.iso"
      source_iso_url_remote = "https://app.vagrantup.com/gusztavvargadr-iso/boxes/windows-11-insider-preview/versions/2302.0.2401/providers/iso/amd64/vagrant.box"
      source_iso_checksum   = "sha256:1cbe4d3a7c8435c9c3d87631c12d33eff585f73d79519f802fb1d83763d5f700"

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
