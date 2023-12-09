packer {
  required_version = "~> 1.9"
}

variable "author" {
  type    = string
  default = "gusztavvargadr"
}

variable "version" {
  type    = string
  default = "2311"
}

variable "images" {
  type = map(map(map(string)))
}

variable "image" {
  type = string
}

variable "provider" {
  type = string
}

variable "build" {
  type = string
}

variable "userprofile_directory" {
  type    = string
  default = env("USERPROFILE")
}

variable "home_directory" {
  type    = string
  default = env("HOME")
}

locals {
  image_options = var.images[var.image]

  image_name        = local.image_options.core.image_name
  image_description = local.image_options.core.image_description
  image_version     = "${local.image_options.core.image_version}.${var.version}"
  image_provider    = var.provider

  artifacts_directory = "${path.cwd}/../../artifacts/${local.image_name}/${local.image_provider}/${var.build}"
}
