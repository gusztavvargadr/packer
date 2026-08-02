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
| Windows 11 Version 25H2 Professional | ARM64 | VirtualBox, VMware |

### Ubuntu Desktop release components

| Image | Native source |
| --- | --- |
| Ubuntu Desktop 24.04 LTS | `ubuntu-24.04.4-desktop-arm64.iso` (`sha256:c2610520bf582976839a1724c669e1cfed0547427be5a0ad12d457b92b46ffbe`) |
| Ubuntu Desktop 22.04 LTS | Matching-provider `ubuntu-server/2204-lts-arm64` native image, built from `ubuntu-22.04.5-live-server-arm64.iso` (`sha256:eafec62cfe760c30cac43f446463e628fada468c2de2f14e0e2bc27295187505`) |

VirtualBox Guest Additions are not installed on Ubuntu ARM64 images because [VirtualBox does not list Ubuntu among the supported ARM64 Guest Additions platforms](https://www.virtualbox.org/manual/topics/guestadditions.html). VMware uses Ubuntu's `open-vm-tools` and `open-vm-tools-desktop` packages. Each authoritative pipeline run records the exact host, provider, Packer, plugin, Vagrant, and guest-tool versions used for validation.

### Prerequisites

- An Apple-silicon Mac running the latest stable macOS release
- The latest stable VirtualBox release, or the latest stable VMware Fusion release and VMware Utility
- The latest stable Packer and Vagrant releases, including the provider's Packer and Vagrant plugins
- Sufficient free disk space for the installation ISO, native image, and Vagrant box

Windows builds require the manually downloaded Windows 11 25H2 ARM64 installation ISO. VirtualBox builds download and install Guest Additions for the exact host VirtualBox version using the existing version-derived download URL shared across Windows guest architectures. VMware builds obtain the required ARM64 `vmxnet3` boot driver from `drivers-arm64.zip` in the configured VMware Fusion application and download VMware Tools inside the guest from the architecture-specific URL validated for the release. The Fusion application defaults to `/Applications/VMware Fusion.app`; set `PKR_VAR_vmware_fusion_application_path` to use a different location.

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

ARM64 support currently excludes Hyper-V, QEMU/libvirt, and Intel Macs. Additional image and provider combinations will be listed here after their native build, Vagrant packaging, publication, and downloaded-box boot gates pass.
