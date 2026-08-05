# Isolated artifact-handoff benchmark

> BENCHMARK — throw this harness away after the transfer specification is captured.

This harness measures the control and candidate representations selected by [Choose artifact-transfer candidates to benchmark](https://github.com/gusztavvargadr/packer/issues/550). It keeps Azure Pipeline Artifacts at supported defaults and measures one clean AMD64 build agent from tested artifact ready through a separate job's checksum verification.

## Representations

- `control` publishes the tested native image or canonical Vagrant box directly.
- `candidate` publishes the registered-VM OVF plus monolithic-sparse VMDK for VirtualBox native images and exact gzip-decoded raw tar plus its versioned reconstruction manifest for Vagrant boxes.
- Both Hyper-V Vagrant modes first remove exactly `Virtual Machines/box.xml`, require a `.vmcx`, regenerate the box checksum, and run the normal Vagrant test against those canonical bytes. This makes the transfer comparison share the required packaging correction.
- Ubuntu QEMU native remains unchanged in both modes and serves as the efficient environmental control.

The Packer Vagrant plugin is pinned to 1.1.6 on this throwaway branch because exact reconstruction is coupled to that producer's pgzip and DEFLATE dependency set. The VirtualBox plugin is pinned to the producer-prototype's proven 1.1.5 contract. The manifests record the resolved contracts. Both agent hosts require the same system-installed Go version, at least 1.24.2, to satisfy the helper module's `go` directive. Every build and verification job tests and compiles the helper before the first per-operation snapshot, so compilation, module download, and toolchain-cache activity are outside the measured component aggregate.

## Captured boundary

The shared pipeline template adds a clean downstream verification job. JSON snapshots independently bracket transformation, Pipeline Artifact upload, Pipeline Artifact download, reconstruction, and checksum or compatibility verification. Each snapshot records UTC and monotonic timestamps, build and agent identity, operating system and architecture, OS network counters, system CPU counters, drive capacity, and artifact logical size. Helper commands additionally sample free space on their output volume while running to capture their peak temporary-disk consumption. Azure task logs provide task wall time and the service counters, chunk counts, hash type, domain identifier, task version, retries, and warnings. The collector reports both the sum of measured handoff components and the observed tested-artifact-ready through verification-complete cross-job clock. The observed clock intentionally includes Azure queueing, checkout, and verification-job preflight, so use the component sum for representation comparisons and the observed clock as operational context.

The downstream gates are:

- exact checksum verification for control artifacts and Ubuntu QEMU native;
- per-file checksum verification plus `VBoxManage import --dry-run` for VirtualBox native artifacts;
- raw-tar checksum verification and byte-for-byte reconstruction to the source box length and SHA-256 for candidate Vagrant artifacts.

The registered VirtualBox producer separately records process CPU, transformation phases, per-file lengths and SHA-256 values, and peak combined disk allocation. Vagrant transform and reconstruction commands report sampled output-volume peak consumption alongside their source, raw-tar, and reconstructed lengths. Pipeline Artifact upload and download record only boundary disk state because the supported Azure tasks expose no temporary-staging disk counter; do not interpret those boundary values as a sampled service-task peak. Task CPU and wall evidence is retained in the Azure timeline and logs.

## Queue protocol

Queue the existing pipeline definition against branch `codex/measure-isolated-artifact-handoffs`. Set `Artifact transfer representation` to `control` or `candidate` and `Adjacent-build sequence` to `A` or `B`. The two physical hosts are independent scheduling lanes, but each can run only one agent at a time: QEMU and VirtualBox are pinned to the Linux AMD64 host, while Hyper-V and VMware are pinned to the Windows AMD64 host. One Linux run and one Windows run may overlap; never overlap two runs assigned to the same host, even if Azure DevOps exposes different provider-specific agent names. Keep every control/candidate A/B series on its assigned host and keep unrelated network traffic off that host where practical.

Use these definitions:

| Pipeline | Definition | Required artifact patterns |
| --- | ---: | --- |
| `ubuntu-server.2404-lts.qemu` | 611 | QEMU native control and QEMU Vagrant control/candidate |
| `ubuntu-server.2404-lts.virtualbox` | 569 | VirtualBox native control/candidate |
| `windows-11.25h2-enterprise.hyperv` | 638 | Hyper-V Vagrant control/candidate |
| `windows-11.25h2-enterprise.qemu` | 637 | QEMU Vagrant control/candidate |
| `windows-11.25h2-enterprise.virtualbox` | 639 | VirtualBox native and Vagrant control/candidate |
| `windows-11.25h2-enterprise.vmware` | 640 | VMware Vagrant control/candidate |

For every definition and representation, queue `A` and wait for it to finish before queueing `B`. `A` seeds Azure's retained content; `B` is the measured adjacent real build. The optional identical-`B` maximum-reuse sanity check is not exposed because the current pipeline always performs a real rebuild.

Before committing to the full matrix, validate the harness in this order:

1. `ubuntu-server.2404-lts.qemu`, `candidate`, `A` — exercises the shared preflight, Linux snapshots, raw-tar upload, clean download, exact reconstruction, and the unchanged native control.
2. `ubuntu-server.2404-lts.virtualbox`, `candidate`, `A` — exercises the registered-VM producer, canonical native upload, downloaded checksum verification, and OVF import dry-run.
3. `windows-11.25h2-enterprise.hyperv`, `candidate`, `A` — exercises Windows snapshots and the pre-test Hyper-V canonical packager.

If any smoke run changes the harness, discard its measurements and restart its representation at `A` after publishing the corrected branch.

Collect completed public build logs, timeline timestamps, exact artifact sizes, task counters, and snapshot deltas into one JSON dataset and a companion CSV with:

```console
ruby src/prototypes/artifact-transfer-benchmark/collect.rb --output artifacts/artifact-transfer-benchmark/dataset.json <build-id> [<build-id> ...]
```

The collector uses only Azure DevOps' public build, timeline, artifact, and task-log APIs. `DomainId`, `Hashtype`, task versions, and upload/download statistics are normal task output; enabling `system.debug` is unnecessary and would add diagnostic overhead.

## Acceptance

Compare each measured `B` with the corresponding control and its seeding `A`. Calibrate noise from the unchanged Ubuntu QEMU native observations before fixing thresholds. The provisional advancement targets are about 50% fewer physical upload bytes, 30% shorter upload wall time, a shorter measured-component handoff, no representative pattern regressing by more than 10%, and zero integrity or compatibility failures. Record retries, uncontrolled traffic, Azure queue/preflight time, service-task temporary-disk limits, and Azure's undocumented retained-content state as limitations rather than silently treating task counters as NIC bytes.
