variable "builder_destination" {
  type    = string
  default = "C:/Windows/Temp/packer"
}

variable "builder_source" {
  type    = string
  default = "builders"
}

variable "chef_destination" {
  type    = string
  default = "C:/Windows/Temp/chef"
}

variable "chef_max_retries" {
  type    = string
  default = "10"
}

variable "chef_source" {
  type    = string
  default = "provisioners/chef"
}

variable "chef_start_retry_timeout" {
  type    = string
  default = "30m"
}

build {
  provisioner "powershell" {
    script = "${var.builder_source}/${source.type}/scripts/prepare.ps1"
  }

  provisioner "file" {
    destination = "${var.builder_destination}"
    source      = "${var.builder_source}/${source.type}/upload/"
  }

  provisioner "file" {
    destination = "${var.chef_destination}"
    source      = "${var.chef_source}/upload/"
  }

  provisioner "powershell" {
    elevated_password   = "${var.elevated_password}"
    elevated_user       = "${var.elevated_user}"
    inline              = ["cd ${var.chef_destination}; chef-client --local-mode"]
    max_retries         = "${var.chef_max_retries}"
    pause_before        = "1m0s"
    start_retry_timeout = "${var.chef_start_retry_timeout}"
  }
}
