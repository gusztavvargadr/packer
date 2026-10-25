# Product

Packer is a catalog of reusable Windows and Ubuntu machine images for developers who need ready-to-use virtual environments. It supplies Vagrant boxes and the definitions used to build them.

## Why

Preparing an operating system and its development tools repeatedly costs time and makes environments harder to reproduce. The catalog saves developers that work by providing environments they can start and use for development, testing, and related workloads.

## How

Shared foundations keep related environments consistent and reduce repeated setup. Specialized images add the tools needed for a particular user-facing intent rather than making every image contain everything.

Stable consumer-facing names let users follow supported environments without learning the catalog's internal organization. Explicit release, provider, and architecture choices let consumers select the environment they need; canonical names remain truthful about the operating-system release and edition they contain.

## What

The catalog includes Windows Server, Windows 11, Ubuntu Server, Ubuntu Desktop, and Xubuntu Desktop environments, along with images for Docker, Kitchen, IIS, development, and Visual Studio. The [public image catalog](site/images/index.md) describes the available choices and their usage.

Provider coverage includes Hyper-V, QEMU/libvirt, VirtualBox, and VMware, with support varying by image. AMD64 is the established default. The supported ARM64 combinations use VirtualBox or VMware on Apple-silicon Macs; the [ARM64 documentation](site/arm64.md) records their scope and limitations. A provider or architecture appearing in a build definition does not make every combination a supported catalog choice.

The product supplies reusable guest environments. Deploying and managing the applications consumers put into those environments is outside the catalog's purpose.

## Direction

The catalog is directed toward improving the reliability and coverage of its supported images while preserving useful shared foundations and stable consumer-facing names. Progress means consumers can obtain the documented environment for their provider and architecture, start it successfully, and spend less time repairing or repeating machine setup.

## Terms

- **Image catalog**: A collection of image families managed and released together.
- **Image family**: A group of image variants united by the same user-facing intent, even when they target different guest operating systems. Use this term rather than `scenario`.
- **Image variant**: A catalog choice within an image family that fulfills the family's intent for one guest operating system, guest architecture, and a particular operating-system release, edition, desktop, or workload combination.
- **Image source**: The originating content from which a native image is produced, such as installation media, an external machine image, or another image variant. Use this term rather than `source image`.
- **Image artifact**: A provider-specific build result for an image variant.
- **Image artifact type**: The representation of an image artifact. The current types are native image and Vagrant box. Use this term rather than `build kind` or `output kind`.
- **Box artifact origin**: The durable public location from which consumers download a Vagrant box.
- **Vagrant registry entry**: The catalog metadata for a Vagrant box, including its release version, provider, architecture, checksum, and box artifact origin.
- **Alias box**: A Vagrant registry entry with a stable consumer-facing name whose box artifact origin references another registry entry for the same release version, provider, and architecture. Use this term rather than `duplicate box`.
- **Build configuration**: The complete selection of an image family, image variant, provider, and image artifact type.
- **Release**: A catalog-wide publication cohort of image artifacts managed under one release version.
- **Release version**: The identifier shared by the image artifacts participating in a release. Use this term rather than `build version` or `image version`.
