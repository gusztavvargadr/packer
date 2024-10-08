images = {
  "22h2-enterprise" = {
    core = {
      image_description = "Windows 10 Version 22H2 Enterprise"
      image_version     = "2202.0"
    }

    native = {
      source_iso_url_local  = "19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:ef7312733a9f5d7d51cfa04ac497671995674ca5e1058d5164d6028f0938d668"
    }

    vagrant = {
      memory    = "4096"
      box_alias = "windows-10"
    }

    virtualbox = {
      guest_os_type = "Windows10_64"
    }

    vmware = {
      guest_os_type = "windows9-64"
    }
  }

  "21h2-enterprise-ltsc" = {
    core = {
      image_description = "Windows 10 Version 21H2 Enterprise LTSC"
      image_version     = "2102.0"
    }

    native = {
      source_iso_url_local  = "19044.1288.211006-0501.21h2_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso"
      source_iso_url_remote = "https://software-download.microsoft.com/download/db/444969d5-f34g-4e03-ac9d-1f9786c69161/19044.1288.211006-0501.21h2_release_svc_refresh_CLIENT_LTSC_EVAL_x64FRE_en-us.iso"
      source_iso_checksum   = "sha256:e4ab2e3535be5748252a8d5d57539a6e59be8d6726345ee10e7afd2cb89fefb5"

      boot_image_name = "Windows 10 Enterprise LTSC 2021 Evaluation"
    }

    vagrant = {
      memory = "4096"
    }

    virtualbox = {
      guest_os_type = "Windows10_64"
    }

    vmware = {
      guest_os_type = "windows9-64"
    }
  }
}
