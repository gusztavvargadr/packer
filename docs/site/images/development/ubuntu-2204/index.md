---
layout: page
title: Development on Ubuntu 22.04
---

### In the box

[Downloads][BoxOverview]

This box has the following contents:

- Git
- Docker Engine
- .NET SDK
- Ubuntu Desktop 22.04 LTS
- OpenSSH Server
- User `vagrant` with password `vagrant` and Vagrant's default SSH key
- 4 CPUs, 8 GB RAM

[BoxOverview]: https://portal.cloud.hashicorp.com/vagrant/discover/gusztavvargadr/development-ubuntu-2204

### Versions

#### 2607.1.0

[Downloads][BoxVersion260710]

This version provides ARM64 artifacts for VirtualBox and VMware.

This version has the following contents:

- Git 2.54.0
- [Docker Engine 29.7.1](https://docs.docker.com/engine/release-notes/29/#2971)
- Docker Compose 5.4.0
- .NET SDK 10.0.110, 9.0.119, 8.0.129
- [OS Release 22.04.5](https://discourse.ubuntu.com/t/jammy-jellyfish-point-release-changes/29835/8)
- Kernel 5.15.0-186-generic
- VirtualBox Guest Additions are not installed on ARM64
- VMware open-vm-tools 12.3.5

[BoxVersion260710]: https://portal.cloud.hashicorp.com/vagrant/discover/gusztavvargadr/development-ubuntu-2204/versions/2607.1.0

#### 2607.0.0

[Downloads][BoxVersion260700]

This version provides AMD64 artifacts for Hyper-V, libvirt, VirtualBox and VMware, plus an ARM64 artifact for VMware.

This version has the following contents:

- Git 2.54.0
- [Docker Engine 29.6.2](https://docs.docker.com/engine/release-notes/29/#2962)
- Docker Compose 5.3.1
- .NET SDK 10.0.110, 9.0.119, 8.0.129
- [OS Release 22.04.5](https://discourse.ubuntu.com/t/jammy-jellyfish-point-release-changes/29835/8)
- Kernel 5.15.0-186-generic
- Hyper-V Kernel 6.8.0-1063-azure
- QEMU qemu-guest-agent 6.2
- VirtualBox AMD64 [VirtualBox Guest Additions 7.2.14](https://www.virtualbox.org/wiki/Changelog-7.2#v14)
- VMware open-vm-tools 12.3.5

[BoxVersion260700]: https://portal.cloud.hashicorp.com/vagrant/discover/gusztavvargadr/development-ubuntu-2204/versions/2607.0.0

#### 2601.0.0

[Downloads][BoxVersion260100]

This version has the following contents:

- [Docker Engine 29.2.0](https://docs.docker.com/engine/release-notes/29/#2920)
- .NET SDK 10.0.2, 9.0.12, 8.0.23
- [OS Release 22.04.5](https://discourse.ubuntu.com/t/jammy-jellyfish-point-release-changes/29835/8)
- Kernel 5.15.0-168-generic
- Hyper-V Kernel 6.8.0-1044-azure
- QEMU qemu-guest-agent 6.2
- VirtualBox [VirtualBox Guest Additions 7.2.6](https://www.virtualbox.org/wiki/Changelog-7.2#v6)
- VMware open-vm-tools 12.3.5

[BoxVersion260100]: https://portal.cloud.hashicorp.com/vagrant/discover/gusztavvargadr/development-ubuntu-2204/versions/2601.0.0
