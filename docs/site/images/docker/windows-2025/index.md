---
layout: page
title: Docker on Windows 2025
---

### In the box

[Downloads][BoxOverview]

This box has the following contents:

- Docker Engine
- Windows Server 2025 Standard
- OpenSSH Server and WinRM
- Windows Updates disabled
- Maintenance tasks disabled
- Windows Defender disabled
- UAC disabled
- Generalized with Sysprep
- User `vagrant` with password `vagrant` and Vagrant's default SSH key
- 2 CPUs, 2 GB RAM

[BoxOverview]: https://portal.cloud.hashicorp.com/vagrant/discover/gusztavvargadr/docker-community-windows-server

### Versions

#### 2607.0.0

[Downloads][BoxVersion260700]

This version provides AMD64 artifacts for Hyper-V, libvirt, VirtualBox and VMware.

This version has the following contents:

- [Docker Engine 29.6.2](https://docs.docker.com/engine/release-notes/29/#2962)
- Docker Compose 5.3.1
- [OS Build 26100.33158](https://support.microsoft.com/en-us/servicing/os/windows-server/2026/07/july-14-2026-kb5099536-os-build-26100-33158)
- QEMU [VirtIO Drivers 0.1.285](https://fedorapeople.org/groups/virt/virtio-win/CHANGELOG)
- VirtualBox [VirtualBox Guest Additions 7.2.14](https://www.virtualbox.org/wiki/Changelog-7.2#v14)
- VMware [VMware Tools 13.1.0](https://knowledge.broadcom.com/external/article?articleNumber=304809)

[BoxVersion260700]: https://portal.cloud.hashicorp.com/vagrant/discover/gusztavvargadr/docker-community-windows-server/versions/2607.0.0

#### 2601.0.0

[Downloads][BoxVersion260100]

This version has the following contents:

- [Docker Engine 29.2.0](https://docs.docker.com/engine/release-notes/29/#2920)
- [OS Build 26100.32230](https://support.microsoft.com/en-us/topic/january-13-2026-kb5073379-os-build-26100-32230-a6021fd2-b3b7-45a7-b68e-35c28a2a77da)
- QEMU [VirtIO Drivers 0.1.285](https://fedorapeople.org/groups/virt/virtio-win/CHANGELOG)
- VirtualBox [VirtualBox Guest Additions 7.2.6](https://www.virtualbox.org/wiki/Changelog-7.2#v6)
- VMware [VMware Tools 13.0.10](https://techdocs.broadcom.com/us/en/vmware-cis/vsphere/tools/13-0-0/release-notes/vmware-tools-13010-release-notes.html)

[BoxVersion260100]: https://portal.cloud.hashicorp.com/vagrant/discover/gusztavvargadr/docker-community-windows-server/versions/2601.0.0
