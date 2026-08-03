packer {
  required_version = "~> 1.15"
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
  image_catalog_input  = var.images
  image_key_input      = var.image
  image_author_input   = var.author
  image_version_input  = var.version
  image_provider_input = var.provider
  image_build_input    = var.build
}

locals {
  image_options = local.image_catalog_input[local.image_key_input]

  image_key          = local.image_key_input
  image_author       = local.image_author_input
  image_name         = "${basename(path.cwd)}/${local.image_key}"
  image_description  = local.image_options.core.image_description
  image_architecture = lookup(local.image_options.core, "architecture", "amd64")
  image_version      = local.image_version_input
  image_provider     = local.image_provider_input
  image_build        = local.image_build_input

  artifacts_directory = "${path.cwd}/../../artifacts/${local.image_name}/${local.image_provider}/${local.image_build}"
}
