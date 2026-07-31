---
layout: page
title: ARM64 Support
navbar_include: true
---

ARM64 images are native Apple-silicon guest images. They use the same canonical Vagrant box names, release versions, and provider identities as their AMD64 counterparts; Vagrant selects the matching artifact by architecture.

### Supported images

| Image | Architecture | Providers |
| --- | --- | --- |
| [Ubuntu Server 24.04 LTS]({{ site.baseurl }}{% link images/ubuntu-server/2404-lts/index.md %}) | ARM64 | VMware |

### Prerequisites

- An Apple-silicon Mac running the latest stable macOS release
- The latest stable VMware Fusion release and VMware Utility
- The latest stable Packer and Vagrant releases, including the Packer VMware plugin and Vagrant VMware Desktop provider plugin
- Sufficient free disk space for the Ubuntu installation ISO, native image, and Vagrant box

The manually queued ARM64 pipeline is the authoritative end-to-end validation. It requires Azure agents advertising `Agent.OS=Darwin`, `Agent.OSArchitecture=ARM64`, and the existing `vmware` provider capability, and reports the exact macOS, VMware Fusion, Packer, Packer plugin, Vagrant, and Vagrant plugin versions used by each run.

### Using the ARM64 box

Select the ARM64 artifact explicitly when defining a machine:

```ruby
config.vm.box = "gusztavvargadr/ubuntu-server-2404-lts"
config.vm.box_architecture = "arm64"
```

Start the machine with the existing VMware provider identity, for example `vagrant up --provider vmware_desktop`.

The canonical `ubuntu-server-2404-lts` box and the `ubuntu-server` alias remain AMD64 by default for compatibility. ARM64 publication adds an architecture-specific artifact under the normal catalog release version.

ARM64 support currently excludes VirtualBox, Hyper-V, QEMU/libvirt, Windows guests, and Intel Macs. Additional image and provider combinations will be listed here after their native build, Vagrant packaging, publication, and downloaded-box boot gates pass.
