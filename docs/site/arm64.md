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
| Windows 11 Version 25H2 Professional | ARM64 | VMware |

### Prerequisites

- An Apple-silicon Mac running the latest stable macOS release
- The latest stable VirtualBox release, or the latest stable VMware Fusion release and VMware Utility
- The latest stable Packer and Vagrant releases, including the provider's Packer and Vagrant plugins
- Sufficient free disk space for the installation ISO, native image, and Vagrant box

Windows builds require the manually downloaded Windows 11 25H2 ARM64 installation ISO. VMware builds obtain the required ARM64 `vmxnet3` boot driver from `drivers-arm64.zip` in the configured VMware Fusion application and download VMware Tools inside the guest from the architecture-specific URL validated for the release. The Fusion application defaults to `/Applications/VMware Fusion.app`; set `PKR_VAR_vmware_fusion_application_path` to use a different location.

The manually queued ARM64 pipelines are the authoritative end-to-end validation. They require Azure agents advertising `Agent.OS=Darwin`, `Agent.OSArchitecture=ARM64`, and the selected `virtualbox` or `vmware` provider capability, and report the exact macOS, provider, Packer, Packer plugin, Vagrant, Vagrant plugin, and guest-tool versions used by each run.

### Using the ARM64 box

Select the ARM64 artifact explicitly when defining a machine:

```ruby
config.vm.box = "gusztavvargadr/ubuntu-server-2404-lts"
config.vm.box_architecture = "arm64"
```

Start the machine with an existing provider identity, for example `vagrant up --provider virtualbox` or `vagrant up --provider vmware_desktop`.

The canonical `ubuntu-server-2404-lts` box and the `ubuntu-server` alias remain AMD64 by default for compatibility. ARM64 publication adds an architecture-specific artifact under the normal catalog release version.

Windows 11 uses architecture-dependent editions. The generic `windows-11` alias continues to target Windows 11 25H2 Enterprise on AMD64 and targets Windows 11 25H2 Professional on ARM64. The Professional ARM64 artifact is published truthfully as `windows-11-25h2-professional` and defaults to ARM64 because that canonical box is ARM64-only; the multi-architecture alias remains AMD64 by default.

ARM64 support currently excludes Hyper-V, QEMU/libvirt, Windows guests on VirtualBox, and Intel Macs. Additional image and provider combinations will be listed here after their native build, Vagrant packaging, publication, and downloaded-box boot gates pass.
