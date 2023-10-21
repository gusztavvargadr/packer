images = {
  "22h2-enterprise" = {
    core = {
      name        = "w1122h2e"
      description = "Windows 11 Version 22H2 Enterprise"

      iso_url_local  = "22621.525.220925-0207.ni_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      iso_url_remote = "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66751/22621.525.220925-0207.ni_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      iso_checksum   = "sha256:ebbc79106715f44f5020f77bd90721b17c5a877cbc15a3535b99155493a1bb3f"
      setup_script   = "setup.cmd"
    }

    virtualbox = {
      guest_os_type = "Windows10_64"
    }

    vmware = {
      guest_os_type = "windows11-64"
    }
  }

  "21h2-enterprise" = {
    core = {
      name        = "w1121h2e"
      description = "Windows 11 Version 21H2 Enterprise"

      iso_url_local  = "22000.194.210913-1444.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      iso_url_remote = "https://software-download.microsoft.com/download/sg/22000.194.210913-1444.co_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      iso_checksum   = "sha256:e8b1d2a1a85a09b4bf6154084a8be8e3c814894a15a7bcf3e8e63fcfa9a528cb"
      setup_script   = "setup.cmd"
    }

    virtualbox = {
      guest_os_type = "Windows10_64"
    }

    vmware = {
      guest_os_type = "windows11-64"
    }
  }

  "insider-preview-enterprise" = {
    core = {
      name        = "w11ipe"
      description = "Windows 11 Insider Preview Enterprise"

      iso_url_local  = "Windows11_InsiderPreview_EnterpriseVL_x64_en-us_25951.iso"
      iso_url_remote = "https://app.vagrantup.com/gusztavvargadr-iso/boxes/windows-11-insider-preview/versions/2202.0.2310/providers/iso-hosted/amd64/vagrant.box"
      iso_checksum   = "sha256:e771769bc27aec3361bae30ef86addc1f9934553270fea83a38f33d54475dc73"
      setup_script   = "setup.cmd"
      image_name     = "Windows 11 Enterprise"
    }

    virtualbox = {
      guest_os_type = "Windows10_64"
    }

    vmware = {
      guest_os_type = "windows11-64"
    }
  }
}
