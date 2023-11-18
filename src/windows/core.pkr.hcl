packer {
  required_version = "~> 1.9"
}

// buids: native, vagrant
// source: iso, native, (ami), (vagrant?)
// organization: core, builds, providers
// build steps: init, restore, build, test, publish
// local vs variable names
// check todos in notes
// simplify compact ? : conditionals (move to multi-line?)

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

  artifacts_directory = "${path.cwd}/artifacts/${var.image}/${local.image_provider}-${var.build}"
}
