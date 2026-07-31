---
layout: page
title: ARM64 Support
navbar_include: true
---

ARM64 images are native Apple-silicon guest images. They use the same canonical Vagrant box names, release versions, and provider identities as their AMD64 counterparts; Vagrant selects the matching artifact by architecture.

### Supported images

| Image | Architecture | Providers |
| --- | --- | --- |
| [Ubuntu Server 24.04 LTS]({{ site.baseurl }}{% link images/ubuntu-server/2404-lts/index.md %}) | ARM64 | VirtualBox, VMware |
| [Ubuntu Server 22.04 LTS]({{ site.baseurl }}{% link images/ubuntu-server/2204-lts/index.md %}) | ARM64 | VirtualBox, VMware |

### Prerequisites

- An Apple-silicon Mac running the latest stable macOS release
- The latest stable VirtualBox release, or the latest stable VMware Fusion release and VMware Utility
- The latest stable Packer and Vagrant releases, including the provider's Packer and Vagrant plugins
- Sufficient free disk space for the Ubuntu installation ISO, native image, and Vagrant box

The manually queued ARM64 pipelines are the authoritative end-to-end validation. They require Azure agents advertising `Agent.OS=Darwin`, `Agent.OSArchitecture=ARM64`, and the selected `virtualbox` or `vmware` provider capability, and report the exact macOS, provider, Packer, Packer plugin, Vagrant, Vagrant plugin, and guest-tool versions used by each run.

### Using the ARM64 box

Select the ARM64 artifact explicitly when defining a machine:

```ruby
config.vm.box = "gusztavvargadr/ubuntu-server-2404-lts"
config.vm.box_architecture = "arm64"
```

Start the machine with an existing provider identity, for example `vagrant up --provider virtualbox` or `vagrant up --provider vmware_desktop`.

The canonical `ubuntu-server-2404-lts` box and the `ubuntu-server` alias remain AMD64 by default for compatibility. ARM64 publication adds an architecture-specific artifact under the normal catalog release version.

ARM64 support currently excludes Hyper-V, QEMU/libvirt, Windows guests, and Intel Macs. Additional image and provider combinations will be listed here after their native build, Vagrant packaging, publication, and downloaded-box boot gates pass.
