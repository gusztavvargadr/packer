options = {
  "2022-standard" = {
    name        = "ws2022s"
    description = "Windows Server 2022 Standard"

    iso_url_local  = "SERVER_EVAL_x64FRE_en-us.iso"
    iso_url_remote = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
    iso_checksum   = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"

    image_name = "Windows Server 2022 SERVERSTANDARD"

    virtualbox_guest_os_type = "Windows2019_64"
    vmware_guest_os_type     = "windows2019srv-64"
  }

  "2022-standard-core" = {
    name        = "ws2022sc"
    description = "Windows Server 2022 Standard Core"

    iso_url_local  = "SERVER_EVAL_x64FRE_en-us.iso"
    iso_url_remote = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
    iso_checksum   = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"

    image_name = "Windows Server 2022 SERVERSTANDARDCORE"

    virtualbox_guest_os_type = "Windows2019_64"
    vmware_guest_os_type     = "windows2019srv-64"
  }

  "2019-standard" = {
    name        = "ws2019s"
    description = "Windows Server 2019 Standard"

    iso_url_local  = "17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
    iso_url_remote = "https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
    iso_checksum   = "sha256:549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"

    image_name = "Windows Server 2019 SERVERSTANDARD"

    virtualbox_guest_os_type = "Windows2019_64"
    vmware_guest_os_type     = "windows2019srv-64"
  }

  "2019-standard-core" = {
    name        = "ws2019sc"
    description = "Windows Server 2019 Standard Core"

    iso_url_local  = "17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
    iso_url_remote = "https://software-download.microsoft.com/download/pr/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
    iso_checksum   = "sha256:549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"

    image_name = "Windows Server 2019 SERVERSTANDARDCORE"

    virtualbox_guest_os_type = "Windows2019_64"
    vmware_guest_os_type     = "windows2019srv-64"
  }

  "insider-preview-standard" = {
    name        = "wsips"
    description = "Windows Server Insider Preview Standard"

    iso_url_local  = "Windows_InsiderPreview_Server_vNext_en-us_25931.iso"
    iso_url_remote = "https://bit.ly/3QLt7s1"
    iso_checksum   = "sha256:025b7f0dc0013645277173ef890981d3f2d420ded02b14a5fe2f2a9cb1861c80"

    image_name  = "Windows Server 2022 SERVERSTANDARD"
    product_key = "MFY9F-XBN2F-TYFMP-CCV49-RMYVH"

    virtualbox_guest_os_type = "Windows2019_64"
    vmware_guest_os_type     = "windows2019srv-64"
  }

  "insider-preview-standard-core" = {
    name        = "wsipsc"
    description = "Windows Server Insider Preview Standard Core"

    iso_url_local  = "Windows_InsiderPreview_Server_vNext_en-us_25931.iso"
    iso_url_remote = "https://bit.ly/3QLt7s1"
    iso_checksum   = "sha256:025b7f0dc0013645277173ef890981d3f2d420ded02b14a5fe2f2a9cb1861c80"

    image_name  = "Windows Server 2022 SERVERSTANDARDCORE"
    product_key = "MFY9F-XBN2F-TYFMP-CCV49-RMYVH"

    virtualbox_guest_os_type = "Windows2019_64"
    vmware_guest_os_type     = "windows2019srv-64"
  }
}
