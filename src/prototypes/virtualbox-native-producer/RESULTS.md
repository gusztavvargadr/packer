# Registered VirtualBox native producer prototype results

## Question

Can Packer VirtualBox plugin 1.1.5 skip its compressed OVF export while a post-build producer safely emits the validated canonical OVF plus monolithic-sparse VMDK artifact before testing and hashing for representative Ubuntu Server 24.04 and Windows 11 25H2 Enterprise builds?

## Decision

Advance the registered-VM producer to the isolated Azure artifact-handoff benchmark. Configure the Packer VirtualBox source with `skip_export = true` and `keep_registered = true`, require one powered-off VDI at SATA port 0 device 0 plus NVRAM, clone that VDI directly to a monolithic-sparse VMDK, obtain the remaining machine contract from a diskless VirtualBox OVF export, restore and verify the original attachment, add the four disk references to the OVF, validate the result with `VBoxManage import --dry-run`, and atomically replace the registered-VDI handoff with the canonical `image/*.ovf` artifact before final hashing, testing, or publication.

This route avoids the transient compressed export, preserves the existing derived-native and Vagrant consumer interface, and passed local failure injection plus representative Linux-agent builds and real boots for both guests. The `.vbox` plus VDI fallback is unnecessary.

## Producer contract

The prototype fails closed unless it finds exactly one powered-off registered machine backed by the Packer artifact directory, one VDI attached to the SATA controller at port 0 device 0, and one NVRAM file. It records the VM, configuration, NVRAM, disk UUID, capacity, attachment fields, canonical file lengths, SHA-256 hashes, CPU counters, transformation timings, and peak allocated bytes in the versioned `virtualbox-native/registered-ovf-monolithic-sparse/v1` result.

The producer clones the registered VDI with `VBoxManage clonemedium --format VMDK --variant Standard`. It detaches the source disk only while asking VirtualBox to export machine metadata and NVRAM, restores the exact controller, port, device, path, hot-plug, non-rotational, and discard settings in an `ensure` block, then adds the four differences observed between diskless and complete OVFs: the file reference, disk-section entry, RASD disk item, and VirtualBox attached-device image.

The representative wrapper owns the Packer VM after a successful build. It produces into a staging directory, unregisters and deletes that VM, verifies that the old VDI output is empty, atomically installs the canonical `image/` directory, removes stale Packer manifest and checksum files, and generates a new `checksum.sha256` before any native test, consumer build, or artifact publication.

## Local lifecycle fixture

The one-command macOS ARM64 fixture used Packer VirtualBox plugin 1.1.5 and VirtualBox 7.2.14 against a small local disk. It proved Packer failure cleanup, successful registered-machine handoff, an injected producer failure after disk detach, exact attachment restoration, partial-output removal, metadata-only export, OVF reconstruction, import dry-run, representative replacement, checksum regeneration, real import and start, and deletion of every fixture-owned VM. The successful 16 MiB fixture completed the representative producer in about 0.62 seconds and reached a peak combined allocation of 2,957,312 bytes.

## Representative producer measurements

Both representative builds ran on the same Linux AMD64 home-lab agent with VirtualBox 7.2.14. The producer exercised plugin 1.1.5 exactly; the installed Packer CLI version itself differed by run and is not part of the plugin compatibility claim.

| Guest and evidence | Clone | Internal producer | Representative wall | Wrapper CPU | Source allocated | Canonical allocated | Allocated reduction | Peak combined |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| [Ubuntu Server 24.04 build 13107](https://dev.azure.com/gusztavvargadr/packer/_build/results?buildId=13107) | 2.17 s | 13.95 s | 25.58 s | 22.77 CPU-s, 89% | 5,979,508,736 B | 3,795,349,504 B | 36.53% | 9,774,862,336 B |
| [Windows 11 25H2 Enterprise build 13109](https://dev.azure.com/gusztavvargadr/packer/_build/results?buildId=13109) | 18.21 s | 69.61 s | 119.12 s | 99.95 CPU-s, 83% | 32,602,857,472 B | 16,811,782,144 B | 48.43% | 49,414,643,712 B |

The internal timer includes the clone, per-file SHA-256 calculation, metadata-only export, OVF rewrite, medium inspection, import dry-run, and staging measurements. The representative wall timer additionally includes discovery, source-VM unregister/delete, atomic replacement, and final checksum generation. Maximum resident set size was 75,884 KiB for Ubuntu and 74,408 KiB for Windows.

The metadata-only export took 0.069 seconds for Ubuntu and 0.039 seconds for Windows. OVF rewriting remained below one millisecond and import dry-run remained below 24 milliseconds in both runs; disk cloning and hashing dominate the producer.

## Historical time comparison

The preceding [VirtualBox native artifact prototype](../virtualbox-native/RESULTS.md) measured current compressed exports at 87.4 seconds for Ubuntu and 360.9 seconds for Windows, followed by canonical preparation at 25.7 and 148.8 seconds respectively. Those runs were not adjacent controlled builds, so they establish an engineering estimate rather than the final benchmark.

| Guest | Current export alone | Historical export plus prepare | Registered producer wall | Reduction versus export alone | Reduction versus export plus prepare |
| --- | ---: | ---: | ---: | ---: | ---: |
| Ubuntu Server 24.04 | 87.4 s | 113.1 s | 25.58 s | 70.7% | 77.4% |
| Windows 11 25H2 Enterprise | 360.9 s | 509.7 s | 119.12 s | 67.0% | 76.6% |

The earlier prototype did not capture comparable structured CPU counters or the registered-source whole-path peak, so no controlled CPU or temporary-disk saving is claimed. The new producer metrics are sufficient inputs for the isolated adjacent-build benchmark; its peak combined allocation, especially the 49.4 GB Windows observation, remains an explicit capacity constraint.

## Correctness and consumer evidence

| Gate | Ubuntu Server 24.04 | Windows 11 25H2 Enterprise |
| --- | --- | --- |
| Packer handoff | Logged `Skipping export` and retained the powered-off registered VM | Logged `Skipping export` and retained the powered-off registered VM |
| Attachment safety | Detached and restored every recorded disk-attachment field exactly | Detached and restored every recorded disk-attachment field exactly |
| Canonical integrity | OVF, NVRAM, and VMDK lengths and SHA-256 recorded; final checksum regenerated | OVF, NVRAM, and VMDK lengths and SHA-256 recorded; final checksum regenerated |
| Import contract | OVF dry-run passed | OVF dry-run passed |
| Same-run Vagrant consumer | Imported, reached SSH, packaged a box, boot-tested Ubuntu 24.04.4, and cleaned up | Imported, reached SSH, packaged a box, reached WinRM, verified Windows 11 build 26200 and Guest Additions 7.2.14, and cleaned up |
| Separate derived-native consumer | [Kitchen Ubuntu build 13108](https://dev.azure.com/gusztavvargadr/packer/_build/results?buildId=13108) downloaded build 13107, imported and booted the OVF, provisioned through reboot, repackaged and checksummed native and Vagrant artifacts, boot-tested the box, and cleaned up | Not repeated: Ubuntu proved the separate-pipeline derived-native seam, while build 13109 covered the Windows-specific producer, OVF/NVRAM, publication, Vagrant import, boot, WinRM, and cleanup risks |

Build 13107 published the Ubuntu native artifact after the producer and native test, then downloaded it into the Vagrant job; build 13108 independently selected build 13107 as its pipeline resource. Build 13109 published the Windows native artifact after the producer and native test, then downloaded and boot-tested it in its Vagrant job. All native and Vagrant cleanup tasks succeeded.

The producer calculates SHA-256 for every canonical file before OVF validation and regenerates the repository checksum file after atomic replacement. The current derived and Vagrant consumers do not explicitly run `sha256sum --check` against the downloaded source checksum before import; Azure transfer integrity plus successful real imports and boots detected no corruption, but explicit consumer-side checksum enforcement remains a production validation requirement rather than a claim of this prototype.

## Azure transfer observations

The Ubuntu native publication reported 374.1 MB physically uploaded, 1,130.5 MB logically uploaded, and 6,468.2 MB deduplicated; its same-run Vagrant download reported 1,732.6 MB physically downloaded. The Windows native publication reported 3,341.9 MB physically uploaded, 4,957.0 MB logically uploaded, and 28,619.3 MB deduplicated; its same-run Vagrant download reported 13,963.8 MB physically downloaded.

Azure's total-content, progress-denominator, logical-upload, physical-upload, compression, cache, and deduplication counters describe different layers and cannot be compared directly with filesystem logical or allocated bytes. These successful runs demonstrate operational transfer behavior but do not replace the isolated adjacent-build handoff measurement, which must control prior service content and capture upload, download, restoration, NIC bytes, CPU, and wall time together.

## Limitations

The representative Azure runs exercised only the success path; deterministic failure restoration and partial-output cleanup came from the local fixture. Independent checksum enforcement after download is not yet wired into the repository consumers. The prototype requires the observed single-disk SATA topology and aborts rather than generalizing other storage layouts. The Windows Vagrant box publication is a separate terminal-artifact cost and is not evidence about the native producer. Production rollout, fallback, observability, and rollback remain outside this ticket.

## Verdict

The safe canonical OVF producer is viable and should replace the export-plus-clone path as the producer candidate in the isolated Azure benchmark. It eliminates the compressed export, retains the established `image/*.ovf` interface, preserves NVRAM, validates and hashes canonical files before consumers see them, restores caller-owned state on failure, and deletes representative Packer state deterministically after success.

Historical comparisons indicate roughly 67–71% less wall time than compressed export alone and roughly 77% less than export followed by canonical preparation. These are strong producer results, not final transfer-saving claims. Advance this producer and its OVF plus monolithic-sparse VMDK layout to isolated adjacent-build measurement; retain explicit checksum verification and peak-disk guardrails in the benchmark specification, and do not pursue the `.vbox` plus VDI fallback.
