source "null" "assets" {
  communicator = "none"
}

build {
  source "null.assets" {
    name = "assets-core"
  }

  provisioner "shell-local" {
    inline = [
      "cd provisioners/chef",
      "chef install",
      "chef export policies --archive"
    ]
  }
}
