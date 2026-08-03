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
| [Ubuntu Desktop 24.04 LTS]({{ site.baseurl }}{% link images/ubuntu-desktop/2404-lts/index.md %}) | ARM64 | VirtualBox, VMware |
| [Ubuntu Desktop 22.04 LTS]({{ site.baseurl }}{% link images/ubuntu-desktop/2204-lts/index.md %}) | ARM64 | VirtualBox, VMware |
| [Xubuntu Desktop 24.04 LTS]({{ site.baseurl }}{% link images/xubuntu-desktop/2404-lts/index.md %}) | ARM64 | VirtualBox, VMware |
| [Xubuntu Desktop 22.04 LTS]({{ site.baseurl }}{% link images/xubuntu-desktop/2204-lts/index.md %}) | ARM64 | VirtualBox, VMware |
| [Docker on Ubuntu 24.04]({{ site.baseurl }}{% link images/docker/ubuntu-2404/index.md %}) | ARM64 | VirtualBox, VMware |
| [Kitchen on Ubuntu 24.04]({{ site.baseurl }}{% link images/kitchen/ubuntu-2404/index.md %}) | ARM64 | VirtualBox, VMware |
| [Kitchen on Ubuntu 22.04]({{ site.baseurl }}{% link images/kitchen/ubuntu-2204/index.md %}) | ARM64 | VirtualBox, VMware |
| [Development on Ubuntu 24.04]({{ site.baseurl }}{% link images/development/ubuntu-2404/index.md %}) | ARM64 | VirtualBox, VMware |
| [Development on Ubuntu 22.04]({{ site.baseurl }}{% link images/development/ubuntu-2204/index.md %}) | ARM64 | VirtualBox, VMware |
| [Windows 11 Version 25H2 Professional]({{ site.baseurl }}{% link images/windows-11/25h2-professional/index.md %}) | ARM64 | VirtualBox, VMware |

### Requirements and limitations

- An Apple-silicon Mac running the latest stable macOS release
- The latest stable VirtualBox release, or the latest stable VMware Fusion release
- The latest stable Vagrant release; VMware also requires the Vagrant VMware Utility and provider plugin
- Sufficient free disk space for the Vagrant box and virtual machine

VirtualBox Guest Additions are not installed on Ubuntu ARM64 images because [VirtualBox does not list Ubuntu among the supported ARM64 Guest Additions platforms](https://www.virtualbox.org/manual/topics/guestadditions.html). VMware images use the supported guest tools for their operating system.

### Using the ARM64 box

Select the ARM64 artifact explicitly when defining a machine:

```ruby
config.vm.box = "gusztavvargadr/ubuntu-server-2404-lts"
config.vm.box_architecture = "arm64"
```

Start the machine with an existing provider identity, for example `vagrant up --provider virtualbox` or `vagrant up --provider vmware_desktop`.

The canonical `ubuntu-server-2404-lts` box and the `ubuntu-server` alias remain AMD64 by default for compatibility. ARM64 releases add architecture-specific artifacts under the normal catalog versions.

Windows 11 uses architecture-dependent editions. The generic `windows-11` alias continues to target Windows 11 25H2 Enterprise on AMD64 and targets Windows 11 25H2 Professional on ARM64. The Professional ARM64 artifact is published truthfully as `windows-11-25h2-professional` and defaults to ARM64 because that canonical box is ARM64-only; the multi-architecture alias remains AMD64 by default.

ARM64 support currently excludes Hyper-V, QEMU/libvirt, and Intel Macs. Additional image and provider combinations will be listed here after their native build, Vagrant packaging, publication, and downloaded-box boot gates pass.
