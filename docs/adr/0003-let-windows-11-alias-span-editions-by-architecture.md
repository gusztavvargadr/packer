---
status: accepted
---

# Let the Windows 11 alias span editions by guest architecture

Microsoft does not publish a suitable Windows 11 25H2 Enterprise ARM64 evaluation image, while a Professional ARM64 image is available. Publish the ARM64 variant canonically as `windows-11-25h2-professional` and keep the AMD64 Enterprise variant under its existing canonical name; the generic `windows-11` alias may reference Enterprise on AMD64 and Professional on ARM64. The alias denotes the latest supported Windows 11 variant for each guest architecture rather than a common edition across architectures. This preserves a stable multi-architecture alias without misrepresenting the edition of either canonical box, and the architecture-dependent edition difference must be documented for consumers.

This decision was made while defining ARM64 support in [#533](https://github.com/gusztavvargadr/packer/issues/533).
