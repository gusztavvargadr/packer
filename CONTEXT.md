# Machine images

This context describes a catalog of reusable machine images. It provides a shared
language for organizing, producing, and releasing those images.

## Catalog

**Image catalog**:
A collection of image families managed and released together.

**Image family**:
A group of image variants united by the same user-facing intent, even when they
target different guest operating systems.
_Avoid_: scenario

**Image variant**:
A catalog choice within an image family that fulfills the family's intent for one
guest operating system and a particular operating-system release, edition,
desktop, or workload combination.

**Guest operating system**:
The operating system targeted by an image variant, such as Windows or Ubuntu.
_Avoid_: platform

**Image source**:
The originating content from which a native image is produced, such as installation
media, an external machine image, or another image variant.
_Avoid_: source image

## Image artifacts

**Provider**:
The virtualization or cloud backend whose native format and runtime an image
artifact targets, such as Hyper-V, QEMU, VirtualBox, or VMware.

**Image artifact**:
A provider-specific build result for an image variant.

**Image artifact type**:
The representation of an image artifact. The current image artifact types are
native image and Vagrant box.
_Avoid_: build kind, output kind

**Native image**:
A machine image in its provider's native format. It may be used as an image source
or packaged as a Vagrant box.
_Avoid_: Vagrant box

**Vagrant box**:
A versioned, provider-specific distribution package produced from a native image
and consumable by Vagrant.
_Avoid_: native image

**Build configuration**:
The complete selection of an image family, image variant, provider, and image
artifact type.

## Releases

**Release**:
A catalog-wide publication cohort of image artifacts managed under one release
version.

**Release version**:
The identifier shared by the image artifacts participating in a release.
_Avoid_: build version, image version
