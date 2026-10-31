# Architecture

The catalog produces provider-specific native images and packages them as Vagrant boxes. Shared operating-system definitions, sample-specific inputs, and one Cake interface connect local builds to Azure Pipelines; public distribution separates box payloads from registry metadata.

## Catalog inputs and shared foundations

The [product terms](product.md#terms) describe the catalog independently of its directory structure. Current build selection uses `sample/image/provider/build`: `sample` selects a repository partition, `image` selects an entry in its `images.pkrvars.hcl`, and `build` selects the native or Vagrant artifact type. Architecture is an option of the selected image entry, with AMD64 as the default.

An image family is not necessarily one sample. Docker spans `samples/docker-linux/` and `samples/docker-windows/`; Development spans `samples/development-ubuntu/` and `samples/development-windows/`; Kitchen spans `samples/kitchen-ubuntu/` and `samples/kitchen-windows/`. Ubuntu Desktop and Xubuntu Desktop currently share `samples/ubuntu-desktop/`. These are implementation partitions, not alternative definitions of image family.

Samples supply image options, consumer Vagrant definitions, and Chef policies. They depend on the shared Windows or Ubuntu Packer templates and provisioning code. The shared OS definitions select provider adapters and combine their defaults with sample inputs. Chef policies compose repository cookbooks with the reusable assets in the pinned `lib/gusztavvargadr/chef` submodule. Shared provisioning belongs below the samples; image-specific choices enter through sample inputs rather than copied OS templates.

The [root Cake definition](../build.cake) selects the sample and OS, passes external inputs to Packer, and selects the artifact type and stage. Azure Pipelines orchestrates hosts, dependency artifacts, stages, and publication around the same entry point. Build logic shared by local work and CI belongs behind that Cake boundary.

## Native-image dependency chain

A native build starts from installation media when its configuration supplies an ISO checksum, or imports another image variant's native result for the same provider. Imports use the provider's format: OVF for VirtualBox, VMX for VMware, VMCX for Hyper-V, and QEMU disk imports. A Vagrant build imports the selected variant's sibling native result before applying Vagrant-specific preparation and packaging.

Reusing native images avoids repeating expensive operating-system installation and provisioning while keeping provider-specific results throughout the chain. This does not require every desktop to derive from Server: Ubuntu Desktop 24.04 uses its own installation media, while other desktop variants can use a Server native source.

Local Cake execution builds only the selected configuration; it does not recursively build native ancestors. Required native artifacts are already present under the configured artifact paths or arrive from CI. Azure Pipelines downloads a dependency pipeline's `native-build` for a derived native build and the current run's `native-build` for its Vagrant stage. Native results are internal reuse artifacts; public box publication happens through the Vagrant path.

## Artifact transfer and validation

Clean pipeline jobs exchange native results and unpacked Vagrant contents through Azure Pipeline artifacts. The [artifact-transfer module](../src/artifact-transfer/README.md) describes the provider contract, staging and rollback, sparse VirtualBox conversion, and archive handling; those implementation details remain with that module.

Vagrant build output is prepared as unpacked `image` contents for transfer and local boot testing. Publication restores a gzip-compressed `vagrant.box` with libarchive tar and `pigz`, and Packer records its SHA-256 checksum. The compression path has no single-stream gzip fallback.

Vagrant test stages boot and remove the locally built box through the selected provider. The published-box download stage obtains and boots the registry-discovered box separately. Native test and publication stages currently use empty null builds, so a passing native test stage alone supplies no guest-boot evidence. A release shares a version across participating artifacts; the per-configuration jobs do not make catalog publication atomic.

## Payload hosting and registry metadata

Both operating systems publish Vagrant payloads to Cloudflare R2, regardless of box size. HCP Vagrant Registry records versions, providers, architectures, SHA-256 checksums, and external download URLs. This separation keeps payload hosting independent of metadata and discovery and gives publication one path for all payload sizes.

The rclone destination and public origin are configurable through `box_artifact_destination` and `box_artifact_origin`, currently defaulting to `r2:packer` and the `r2.dev` origin in the shared Vagrant definitions. The object key is `<canonical-box-name>/<release-version>/<vagrant-provider>/<architecture>/vagrant.box`. Publication copies only `vagrant.box` with `--checksum --immutable`, then writes canonical registry metadata using its public URL and the Packer checksum. There is no direct-HCP payload fallback. An upload can remain when a later metadata operation fails; these steps are not a transaction.

An alias publishes metadata pointing to the canonical entry's readable `https://vagrantcloud.com/<author>/boxes/<canonical-box-name>/versions/<release-version>/providers/<vagrant-provider>/<architecture>/vagrant.box` URL. It reuses the version, provider, architecture, and checksum rather than uploading a second payload. The box download URL therefore follows alias metadata to canonical metadata and then to the R2 payload.

R2 also keeps the registry metadata and payloads that only HCP stored, because HCP Vagrant operations end on 2026-12-31. These objects in `r2:packer` are released object keys:

- `hcp-vagrant-registry/manifest-20261031T112055Z.json` is a snapshot of the whole `gusztavvargadr` HCP Vagrant registry on 2026-10-31, in the format `vagrant-registry-export registry manifest` writes. It lists every box, version, provider, and architecture with its SHA-256 checksum, including the entries not saved, and is the only object under `hcp-vagrant-registry/`.
- The newest version of each retired canonical box, provider, and architecture is saved under the object key above, 27 AMD64 entries in all. A box is retired when its page under `docs/site/images` marks it deprecated. A retired box gets no further release, so only HCP stored its newest payload; an active box saves nothing from HCP, because its next release is published through R2.
- Each saved entry's release version is in the catalog's `yymm.0.0` form, mapped from its HCP version as the table below states, and each saved object has the SHA-256 the snapshot records for its HCP entry.
- The retired aliases `windows-10` and `sql-server` resolve to `windows-10-22h2-enterprise` and `sql-server-2019-developer-windows-server`, so their payloads are those saved canonical entries.

| Canonical box | HCP version | Release version | Vagrant providers |
| --- | --- | --- | --- |
| `windows-10-22h2-enterprise` | 2511.0.0 | 2511.0.0 | `hyperv`, `libvirt`, `virtualbox`, `vmware_desktop` |
| `windows-11-22h2-enterprise` | 2511.0.0 | 2511.0.0 | `hyperv`, `libvirt`, `virtualbox`, `vmware_desktop` |
| `visual-studio-2022-community-windows-10` | 2511.0.0 | 2511.0.0 | `hyperv`, `libvirt`, `virtualbox`, `vmware_desktop` |
| `windows-10-21h2-enterprise-ltsc` | 2509.0.0 | 2509.0.0 | `hyperv`, `virtualbox`, `vmware_desktop` |
| `windows-server-2019-standard` | 1809.0.2407 | 2407.0.0 | `hyperv`, `virtualbox`, `vmware_desktop` |
| `windows-server-2019-standard-core` | 1809.0.2407 | 2407.0.0 | `hyperv`, `virtualbox`, `vmware_desktop` |
| `sql-server-2019-developer-windows-server` | 2019.2102.2503 | 2503.0.0 | `hyperv`, `virtualbox`, `vmware_desktop` |
| `sql-server-2019-developer-windows-server-core` | 2019.2102.2503 | 2503.0.0 | `hyperv`, `virtualbox`, `vmware_desktop` |

## Architecture-dependent catalog choices

Provider maps distinguish Packer provider names from Vagrant identities: `vmware` becomes `vmware_desktop`, and `qemu` becomes `libvirt`. Support is the documented and validated image/provider/architecture combination, not the Cartesian product of those maps. Current ARM64 pipelines target VirtualBox and VMware on macOS ARM64; the [consumer documentation](site/arm64.md) records their supported combinations and guest-tool limitations.

The generic `windows-11` alias points to 25H2 Enterprise on AMD64 and 25H2 Professional on ARM64. Canonical names identify the actual editions: `windows-11-25h2-enterprise` and `windows-11-25h2-professional`. The alias represents the latest supported Windows 11 choice for each guest architecture rather than promising a common edition. This keeps the consumer-facing alias stable while the canonical names remain truthful. The Professional canonical box defaults to ARM64; the shared alias defaults to AMD64 through provider-specific registry metadata. Consumers can select architecture explicitly.

## Invariants

- A derived native image and a Vagrant package MUST reuse native artifacts for their selected provider; a provider's output MUST NOT be substituted for another provider's native format.
- Image-specific options MUST enter through sample configuration rather than duplicated shared OS templates.
- Packer variables MUST capture external input only. Descriptively named locals MUST represent those inputs and all derived values used by the templates.
- Repository-owned build logic shared by local work and CI MUST run through Cake targets or Cake-invoked helpers. Pipeline YAML MUST remain orchestration around that boundary.
- Artifact transfer MUST preserve provider importability, and the publication checksum MUST describe the final compressed box bytes.
- A released R2 object key MUST remain immutable. Publication MUST NOT select a different payload-hosting path by size or fall back to direct HCP upload.
- An alias MUST reference its canonical entry for the same release version, provider, and architecture without duplicating the payload.
- Canonical box names MUST identify their actual OS release and edition. A Windows 11 alias whose edition varies by guest architecture MUST disclose that difference in consumer documentation.
- A sample directory MUST NOT be treated as the definition of an image family; Docker, Development, and Kitchen each span their current OS-specific samples.
