images = {
  "2025-standard" = {
    core = {
      image_description = "Windows Server 2025 Standard"
    }

    native = {
      source_iso_url_local  = "26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:d0ef4502e350e3c6c53c15b1b3020d38a5ded011bf04998e950720ac8579b23d"

      boot_image_name = "Windows Server 2025 SERVERSTANDARD"
    }

    vagrant = {
      box_alias = "windows-server"
    }

    virtualbox = {
      guest_os_type = "Windows2025_64"
    }

    vmware = {
      guest_os_type = "windows2022srvnext-64"
    }
  }

  "2025-standard-core" = {
    core = {
      image_description = "Windows Server 2025 Standard Core"
    }

    native = {
      source_iso_url_local  = "26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/dbazure/888969d5-f34g-4e03-ac9d-1f9786c66749/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:d0ef4502e350e3c6c53c15b1b3020d38a5ded011bf04998e950720ac8579b23d"

      boot_image_name = "Windows Server 2025 SERVERSTANDARDCORE"
    }

    vagrant = {
      box_alias = "windows-server-core"
    }

    virtualbox = {
      guest_os_type = "Windows2025_64"
    }

    vmware = {
      guest_os_type = "windows2022srvnext-64"
    }
  }

  "2022-standard" = {
    core = {
      image_description = "Windows Server 2022 Standard"
    }

    native = {
      source_iso_url_local  = "SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"

      boot_image_name = "Windows Server 2022 SERVERSTANDARD"
    }

    virtualbox = {
      guest_os_type = "Windows2022_64"
    }

    vmware = {
      guest_os_type = "windows2019srvnext-64"
    }
  }

  "2022-standard-core" = {
    core = {
      image_description = "Windows Server 2022 Standard Core"
    }

    native = {
      source_iso_url_local  = "SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"

      boot_image_name = "Windows Server 2022 SERVERSTANDARDCORE"
    }

    virtualbox = {
      guest_os_type = "Windows2022_64"
    }

    vmware = {
      guest_os_type = "windows2019srvnext-64"
    }
  }

  "insider-preview-standard" = {
    core = {
      image_description = "Windows Server Insider Preview Standard"
    }

    native = {
      source_iso_url_local  = "Windows_InsiderPreview_Server_vNext_en-us_26534.iso"
      source_iso_url_remote = "https://api.hashicorp.cloud/vagrant/2022-08-01/gusztavvargadr-iso/boxes/windows-server-insider-preview/versions/2511.0.0/providers/iso/amd64/vagrant.box"
      source_iso_checksum   = "sha256:7dd34745b2837006db8996b09cbd11a750cb9519f6e92b78fe229739a61f59d8"

      boot_image_name  = "Windows Server 2025 SERVERSTANDARD"
      boot_product_key = "MFY9F-XBN2F-TYFMP-CCV49-RMYVH"
    }

    virtualbox = {
      guest_os_type = "Windows2025_64"
    }

    vmware = {
      guest_os_type = "windows2022srvnext-64"
    }
  }

  "insider-preview-standard-core" = {
    core = {
      image_description = "Windows Server Insider Preview Standard Core"
    }

    native = {
      source_iso_url_local  = "Windows_InsiderPreview_Server_vNext_en-us_26534.iso"
      source_iso_url_remote = "https://api.hashicorp.cloud/vagrant/2022-08-01/gusztavvargadr-iso/boxes/windows-server-insider-preview/versions/2511.0.0/providers/iso/amd64/vagrant.box"
      source_iso_checksum   = "sha256:7dd34745b2837006db8996b09cbd11a750cb9519f6e92b78fe229739a61f59d8"

      boot_image_name  = "Windows Server 2025 SERVERSTANDARDCORE"
      boot_product_key = "MFY9F-XBN2F-TYFMP-CCV49-RMYVH"
    }

    virtualbox = {
      guest_os_type = "Windows2025_64"
    }

    vmware = {
      guest_os_type = "windows2022srvnext-64"
    }
  }
}
