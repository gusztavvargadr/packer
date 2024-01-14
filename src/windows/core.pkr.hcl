packer {
  required_version = "~> 1.9"
}

variable "author" {
  type = string
}

variable "version" {
  type = string
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

locals {
  image_options = var.images[var.image]

  image_author      = var.author
  image_name        = "${basename(path.cwd)}/${var.image}"
  image_description = local.image_options.core.image_description
  image_version     = "${local.image_options.core.image_version}.${var.version}"
  image_provider    = var.provider
  image_build       = var.build

  artifacts_directory = "${path.cwd}/../../artifacts/${local.image_name}/${local.image_provider}/${var.build}"
}
