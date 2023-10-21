images = {
  "22h2-enterprise" = {
    core = {
      name        = "w1022h2e"
      description = "Windows 10 Version 22H2 Enterprise"

      iso_url_local  = "19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      iso_url_remote = "https://software-static.download.prss.microsoft.com/dbazure/988969d5-f34g-4e03-ac9d-1f9786c66750/19045.2006.220908-0225.22h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"
      iso_checksum   = "sha256:ef7312733a9f5d7d51cfa04ac497671995674ca5e1058d5164d6028f0938d668"
    }

    virtualbox = {
      guest_os_type = "Windows10_64"
    }

    vmware = {
      guest_os_type = "windows9-64"
    }
  }
}
