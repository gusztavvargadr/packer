images = {
  "2022-standard" = {
    core = {
      image_description = "Windows Server 2022 Standard"
      image_version     = "2102.0"
    }

    native = {
      source_iso_url_local  = "SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"

      boot_image_name = "Windows Server 2022 SERVERSTANDARD"
    }

    vagrant = {
      box_alias = "windows-server"
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
      image_version     = "2102.0"
    }

    native = {
      source_iso_url_local  = "SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"

      boot_image_name = "Windows Server 2022 SERVERSTANDARDCORE"
    }

    vagrant = {
      box_alias = "windows-server-core"
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
      image_version     = "2402.0"
    }

    native = {
      source_iso_url_local  = "Windows_InsiderPreview_Server_vNext_en-us_26296.iso"
      source_iso_url_remote = "https://api.hashicorp.cloud/vagrant/2022-08-01/gusztavvargadr-iso/boxes/windows-server-insider-preview/versions/2402.0.2409/providers/iso/amd64/vagrant.box"
      source_iso_checksum   = "sha256:05713d5d6aadfb52d84a36836c46ba99396be3217ca2434ca0a5c4c824571a43"

      boot_image_name  = "Windows Server 2025 SERVERSTANDARD"
      boot_product_key = "MFY9F-XBN2F-TYFMP-CCV49-RMYVH"
    }

    virtualbox = {
      guest_os_type = "Windows2022_64"
    }

    vmware = {
      guest_os_type = "windows2019srvnext-64"
    }
  }

  "insider-preview-standard-core" = {
    core = {
      image_description = "Windows Server Insider Preview Standard Core"
      image_version     = "2402.0"
    }

    native = {
      source_iso_url_local  = "Windows_InsiderPreview_Server_vNext_en-us_26296.iso"
      source_iso_url_remote = "https://api.hashicorp.cloud/vagrant/2022-08-01/gusztavvargadr-iso/boxes/windows-server-insider-preview/versions/2402.0.2409/providers/iso/amd64/vagrant.box"
      source_iso_checksum   = "sha256:05713d5d6aadfb52d84a36836c46ba99396be3217ca2434ca0a5c4c824571a43"

      boot_image_name  = "Windows Server 2025 SERVERSTANDARDCORE"
      boot_product_key = "MFY9F-XBN2F-TYFMP-CCV49-RMYVH"
    }

    virtualbox = {
      guest_os_type = "Windows2022_64"
    }

    vmware = {
      guest_os_type = "windows2019srvnext-64"
    }
  }
}
