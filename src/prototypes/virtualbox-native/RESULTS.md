# VirtualBox native artifact prototype results

## Question

Can the current compressed VirtualBox OVF/VMDK native image become a portable uncompressed canonical native image before testing and hashing, while preserving the `image/*.ovf` interface used by derived native and Vagrant builds?

## Decision

Advance an OVF plus monolithic-sparse VMDK candidate to the isolated Azure benchmark. Keep the current native artifact directory role and the `image/*.ovf` entry point; replace the appliance's `streamOptimized` VMDK with a VMDK cloned by `VBoxManage clonemedium --format VMDK --variant Standard`, change the OVF disk-format suffix from `#streamOptimized` to `#sparse`, and update the OVF's disk UUID references to the clone's UUID.

The smallest consumer contract is one OVF, one referenced VMDK, and any appliance companion files such as NVRAM under `image/`. Derived native and Vagrant builds both discover only `image/*.ovf`; source-artifact Chef policy, Packer manifest, and source checksum files are not part of the import interface. The canonical producer must add a versioned manifest containing every canonical file's relative path, logical length, and SHA-256, and acceptance must re-hash those files before `VBoxManage import --dry-run` or a real consumer boot.

The primary layout passed, so the `.vbox` plus VDI fallback is unnecessary.

## Source artifacts

The representative inputs were the published native artifacts from [Ubuntu Server 24.04 build 13075](https://dev.azure.com/gusztavvargadr/packer/_build/results?buildId=13075) and [Windows 11 25H2 Enterprise build 13045](https://dev.azure.com/gusztavvargadr/packer/_build/results?buildId=13045). Both were produced by VirtualBox 7.2.14 and contained one `dynamic streamOptimized` VMDK plus OVF and NVRAM files.

| Guest | Source VMDK bytes | Source VMDK SHA-256 | Current export time |
| --- | ---: | --- | ---: |
| Ubuntu Server 24.04 | 1,739,610,112 | `a257a346cf70198f454331c4d0189e4d165ef95da243ba391d93c32bb5b73e29` | 87.4 s |
| Windows 11 25H2 Enterprise | 14,515,738,112 | `f5187e509219150ae14aee5d8a82d4e7e5a7b6b25a8f329e1ed5c28029d1c2ac` | 360.9 s |

The Windows control is the measured native-transfer outlier: its 14.516 GB artifact physically uploaded 13.969 GB, or 96.2%, in 636.9 seconds. Existing runs cannot control Azure's prior content state, so this observation motivates rather than substitutes for the isolated adjacent-build benchmark.

## Transformation results

The main measurements below were taken on the Linux AMD64 build agent with VirtualBox 7.2.14. Logical and allocated totals cover the OVF appliance files under `image/`; allocated bytes are filesystem-dependent point-in-time measurements.

| Guest | Source logical | Canonical logical | Logical change | Source allocated | Canonical allocated | Clone | Total prepare | OVF dry-run |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Ubuntu Server 24.04 | 1,740,159,154 | 3,996,803,241 | +129.7% | 1,740,169,216 | 3,981,643,776 | 9.1 s | 25.7 s | Pass |
| Windows 11 25H2 Enterprise | 14,516,298,030 | 17,291,119,397 | +19.1% | 14,516,310,016 | 17,277,394,944 | 50.9 s | 148.8 s | Pass |

The total preparation timer includes source and canonical SHA-256 calculation, file copying and OVF rewriting, `VBoxManage showmediuminfo`, cloning, and the import dry-run. It is not a clean estimate of the incremental production transform; the benchmark must time transformation, hashing, and verification separately.

The same conversions ran on macOS ARM64 with VirtualBox 7.2.14 and produced the same logical lengths, capacity, and `dynamic default` medium variant. Ubuntu cloned in 3.9 seconds and Windows in 23.4 seconds; both import dry-runs passed. Canonical VMDK and OVF hashes differ between independent conversions because VirtualBox assigns a new random medium UUID, but each host's subsequent verification reproduced its own recorded path, length, and SHA-256 exactly. NVRAM bytes remained identical to the source.

## Compatibility results

All real consumer checks ran on the Linux AMD64 build agent against the canonical artifacts at the repository paths expected by the shared templates.

| Gate | Ubuntu Server 24.04 | Windows 11 25H2 Enterprise |
| --- | --- | --- |
| Independent checksum and OVF verification | Exact files and import dry-run passed | Exact files and import dry-run passed |
| Native boot | Packer imported the OVF, started the VM, and connected over SSH in 12 seconds | Packer imported the OVF, started the VM, and connected over SSH in 40 seconds |
| Derived native consumption | `kitchen-ubuntu/2404/virtualbox/native` provisioned and emitted a checksummed derived appliance in 5m22s | Prototype Kitchen consumer provisioned across expected Windows reboots and emitted a checksummed derived appliance in 31m44s |
| Vagrant packaging | Packer emitted a checksummed box in 1m28s | Packer emitted a checksummed box in 8m05s |
| Packaged-box boot and test | Vagrant imported the box, reached SSH, verified Ubuntu 24.04.4, provisioned, and cleaned up | Vagrant imported the box, reached WinRM, verified Windows 11 Enterprise 25H2 build 26200, provisioned, and cleaned up |

The commands exercising the existing interfaces were:

```console
dotnet cake --configuration kitchen-ubuntu/2404/virtualbox/native
dotnet cake --configuration ubuntu-server/2404-lts/virtualbox/vagrant
dotnet cake --configuration kitchen-windows/prototype-windows-11-25h2-enterprise/virtualbox/native
dotnet cake --configuration windows-11/25h2-enterprise/virtualbox/vagrant
```

The Windows derived log contains Chef `ERROR` and `FATAL` messages for exit code 35; these are the pipeline's expected reboot signal and were followed by successful retries and a successful final build. The current shared builders export derived and Vagrant outputs in the existing compressed form. These runs validate consumption of the canonical input; a production native producer would apply canonicalization to each native output before its final test, checksum, and upload.

## Azure-visible structure hypothesis

The current stream-optimized VMDK is a compressed grain stream. Changed guest blocks can change compressed byte ranges, and the already-compressed bytes give Azure less opportunity to compress missing content. That mechanism is consistent with, but not proved by, the Windows control's 96.2% physical upload.

The candidate monolithic-sparse VMDK stores uncompressed guest grains behind VMDK metadata. Unchanged guest blocks should remain as reusable ordinary byte ranges, zeroed free space should be highly compressible when chunks are missing, and a new medium UUID should affect only small descriptor and OVF regions. Azure Pipeline Artifacts performs content chunking and service-side reuse, so this representation is likely to expose more stable and compressible content than a compressed stream. Only adjacent real build A/B measurements can establish whether those expected properties survive VirtualBox's grain placement and Azure's chunk boundaries.

The candidate deliberately trades logical size for expected reuse: +19.1% for the representative Windows image and +129.7% for Ubuntu. A cold upload can therefore regress, especially for Ubuntu. Advancement requires the agreed full-handoff measurements and guardrails: transformation, upload, download, verification, NIC bytes, Azure counters, CPU, peak temporary disk, zero compatibility failures, and no representative pattern regressing more than the calibrated threshold.

## Export-time limitation

This prototype canonicalizes the result of VirtualBox's current export, so its transformation is additive to the observed 87.4-second Ubuntu and 360.9-second Windows export costs. Independent compatibility runs repeated the behavior: Ubuntu exports took about 64 seconds, while Windows exports took 284–308 seconds and saturated one CPU according to operator observation.

Packer VirtualBox plugin 1.1.5 supports `skip_export` and `keep_registered`; `skip_export` bypasses `VBoxManage export`, but the plugin then returns its output directory without producing an OVF. Eliminating the compressed export while retaining this OVF contract therefore needs a separate producer prototype that obtains the registered VM's disk and machine metadata, emits the canonical VMDK/OVF safely, and proves cleanup behavior. It is a newly surfaced optimization, not part of the representation decision proved here.

## Verdict

The OVF plus monolithic-sparse VMDK layout is viable as a portable VirtualBox native artifact representation. It preserves both repository consumers, passes real native and Vagrant boots for representative Ubuntu and Windows guests, and has an explicit per-file integrity contract. Advance it to the isolated Azure artifact handoff benchmark; do not claim transfer savings until adjacent-build measurements compare physical upload bytes, upload wall time, and the full handoff against the compressed control.

Separately prototype bypassing VirtualBox's compressed export. If that producer cannot recreate the OVF contract safely, revisit `.vbox` plus VDI as a producer/layout alternative rather than burdening this successful import candidate with unproven machinery.
