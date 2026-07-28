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
      memory    = "4096"
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
      memory    = "4096"
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
