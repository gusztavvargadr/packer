# Current image-artifact transfer baseline

## Question

What do existing Azure Pipelines runs show about logical artifact size, physical bytes uploaded, upload wall time, and effective throughput for native images and Vagrant boxes by provider and guest operating system?

## Answer

The existing runs confirm two distinct transfer profiles. In the representative Ubuntu 24.04 matrix, native artifacts uploaded only 0.2–4.6% of their manifest-reported size, whereas QEMU, VirtualBox, and VMware Vagrant artifacts uploaded 91–95%. Hyper-V's Ubuntu Vagrant artifact was an exception at 3.2%, showing that the Vagrant pattern is not universal and that a single historical observation cannot separate artifact structure from prior service content. In the representative Windows 11 25H2 matrix, Vagrant artifacts uploaded 80–96% of their size; native Hyper-V, QEMU, and VMware artifacts uploaded 14–37%, but native VirtualBox uploaded 96%.

For uploads above 1 GB of physical content, effective physical-upload rates were approximately 61–186 Mbps, with all but one at 105 Mbps or higher. These are end-to-end rates over the complete `Publish artifacts` task, not direct network-interface measurements. On a shared 1 Gbps home-lab uplink, physical bytes are therefore the main lever visible in this evidence: a 14–15 GB Vagrant upload occupied its task for roughly 11–17 minutes, while highly deduplicated native uploads completed in roughly 12–25 seconds despite multi-gigabyte artifacts.

The data is sufficient to justify controlled optimization experiments, but not to set final success thresholds. Existing runs do not expose or control the prior content available to Azure's artifact service, and most configurations have only one observation. A benchmark should first repeat one isolated configuration from a clean agent workspace, then repeat the winning candidate with two concurrent agents.

## Method

The sample uses the two runs named in the ticket, then expands to one consistent Ubuntu 24.04 configuration and one substantial Windows 11 25H2 configuration across Hyper-V, QEMU, VirtualBox, and VMware. The Ubuntu runs all used repository commit [`121e88f`](https://github.com/gusztavvargadr/packer/commit/121e88f261b4672bc67487ea7a20890e0937fc08); the Windows runs used [`d732621`](https://github.com/gusztavvargadr/packer/commit/d7326213accfe705f69d841985b70b583f1661d5). Build 13012 is retained as a supplementary Windows Server 2022 VirtualBox observation because it was the second run supplied with the question.

Each measurement comes from three first-party Azure Pipelines REST resources: the build artifact resource's exact `resource.properties.artifactsize`, the task timeline's start and finish timestamps, and the raw `Publish artifacts` task log's `Physical Content Uploaded`. The task log reports physical content to one decimal MB, so physical GB and derived rates are approximate. The formulas are `physical ratio = reported physical MB / exact artifact bytes` and `effective Mbps = reported physical MB × 8 / complete task seconds`.

The artifact task's `Total Content` statistic was not used as logical artifact size. It is almost exactly twice `resource.properties.artifactsize` in every sampled upload—for example, build 12967 reports artifact sizes of 3,922,429,482 and 1,670,012,530 bytes in its [artifact resources](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/12967/artifacts?api-version=7.1), while its [native log](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/12967/logs/14?api-version=7.1) and [Vagrant log](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/12967/logs/30?api-version=7.1) report `Total Content` of 7,844.6 and 3,340.0 MB. The cause of that discrepancy is outside this empirical baseline; using the manifest property avoids treating the doubled statistic as artifact bytes.

The run-time pipeline configuration requested a clean workspace for each build job and published the complete provider/build directory as either `native-build` or `vagrant-build`; Vagrant build jobs first downloaded the current run's native artifact. These settings are visible in the exact [pipeline definition used by the Windows runs](https://github.com/gusztavvargadr/packer/blob/d7326213accfe705f69d841985b70b583f1661d5/.azure-pipelines/jobs.yml#L16-L17) and its [download and publish steps](https://github.com/gusztavvargadr/packer/blob/d7326213accfe705f69d841985b70b583f1661d5/.azure-pipelines/jobs.yml#L67-L85); the file did not change between the two sampled commits.

## Ubuntu 24.04 baseline

Logical size is the artifact resource's exact byte count displayed here in decimal GB. Physical GB uses the task log's rounded decimal MB. `Isolated` means no other Azure `Publish artifacts` task in the available build timelines overlapped the measured task; it does not rule out non-Azure traffic on the uplink.

| Provider | Artifact and source | Logical GB | Physical GB | Physical ratio | Task wall time | Effective Mbps | Observed upload contention |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| Hyper-V | [native, build 12966](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/12966/logs/14?api-version=7.1) | 4.204 | 0.032 | 0.8% | 23.4 s | 11.0 | Isolated |
| Hyper-V | [Vagrant, build 12966](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/12966/logs/30?api-version=7.1) | 1.533 | 0.049 | 3.2% | 11.0 s | 35.4 | Isolated |
| QEMU | [native, build 12967](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/12967/logs/14?api-version=7.1) | 3.922 | 0.009 | 0.2% | 24.9 s | 2.9 | Isolated |
| QEMU | [Vagrant, build 12967](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/12967/logs/30?api-version=7.1) | 1.670 | 1.522 | 91.1% | 95.2 s | 128.0 | Isolated |
| VirtualBox | [native, build 12983](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/12983/logs/14?api-version=7.1) | 1.668 | 0.076 | 4.6% | 12.2 s | 49.9 | Isolated |
| VirtualBox | [Vagrant, build 12983](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/12983/logs/30?api-version=7.1) | 1.663 | 1.585 | 95.3% | 120.9 s | 104.9 | Isolated |
| VMware | [native, build 12995](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/12995/logs/14?api-version=7.1) | 4.377 | 0.009 | 0.2% | 19.9 s | 3.6 | Isolated |
| VMware | [Vagrant, build 12995](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/12995/logs/30?api-version=7.1) | 1.795 | 1.655 | 92.2% | 112.2 s | 118.1 | Isolated |

The native results show that Azure transferred very little physical content for all four providers in this Ubuntu set. The Vagrant results are sharply different for QEMU, VirtualBox, and VMware, each transferring more than 90% of artifact bytes. Hyper-V's 49 MB Vagrant transfer is an important counterexample: the current logs establish that this run reused most content, but cannot establish whether the result came from the artifact's structure, similarity to prior uploads, or service-side content history.

## Windows baseline

The primary Windows comparison uses Windows 11 25H2 Enterprise across all four providers. The Windows Server 2022 VirtualBox rows are supplementary evidence from build 13012.

| Provider | Artifact and source | Logical GB | Physical GB | Physical ratio | Task wall time | Effective Mbps | Observed upload contention |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- |
| Hyper-V | [native, build 13037](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/13037/logs/14?api-version=7.1) | 18.665 | 2.621 | 14.0% | 202.1 s | 103.7 | Overlapped build 13036's Vagrant upload for 202 s |
| Hyper-V | [Vagrant, build 13037](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/13037/logs/30?api-version=7.1) | 12.157 | 9.683 | 79.7% | 417.5 s | 185.5 | Isolated |
| QEMU | [native, build 13044](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/13044/logs/30?api-version=7.1) | 17.568 | 3.650 | 20.8% | 239.6 s | 121.9 | Isolated |
| QEMU | [Vagrant, build 13044](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/13044/logs/46?api-version=7.1) | 14.948 | 14.387 | 96.2% | 853.5 s | 134.9 | Isolated |
| VirtualBox | [native, build 13045](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/13045/logs/14?api-version=7.1) | 14.516 | 13.969 | 96.2% | 636.9 s | 175.5 | Isolated |
| VirtualBox | [Vagrant, build 13045](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/13045/logs/30?api-version=7.1) | 15.154 | 14.277 | 94.2% | 644.8 s | 177.1 | Isolated |
| VMware | [native, build 13036](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/13036/logs/14?api-version=7.1) | 17.873 | 6.572 | 36.8% | 429.5 s | 122.4 | Isolated |
| VMware | [Vagrant, build 13036](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/13036/logs/30?api-version=7.1) | 15.755 | 15.109 | 95.9% | 1,012.2 s | 119.4 | Overlapped build 13037's native upload for 202 s |
| VirtualBox, Windows Server 2022 | [native, build 13012](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/13012/logs/14?api-version=7.1) | 8.568 | 1.165 | 13.6% | 153.1 s | 60.9 | Isolated |
| VirtualBox, Windows Server 2022 | [Vagrant, build 13012](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/13012/logs/30?api-version=7.1) | 9.201 | 8.223 | 89.4% | 368.0 s | 178.8 | Overlapped [build 13014](https://dev.azure.com/gusztavvargadr/packer/_apis/build/builds/13014/timeline?api-version=7.1) for the final 4 s |

Windows Vagrant uploads consistently transferred most artifact bytes in this sample. The Windows 11 VirtualBox native upload is the clearest provider-specific outlier: it transferred 13.969 GB, nearly four times QEMU's physical bytes and more than twice VMware's, despite having the smallest native artifact. Build 13012 shows that the provider alone does not determine the native result: its Windows Server 2022 VirtualBox artifact transferred only 13.6% while its Vagrant artifact still transferred 89.4%.

Build 13036's Vagrant task and build 13037's native task are the only substantial concurrent-upload pair in the representative matrix. Their combined effective rate over the 202-second overlap cannot be derived precisely from final counters, and the two artifacts had different physical ratios. They are therefore evidence that uncontrolled contention exists, not a valid two-agent benchmark.

## Limitations and next measurement

- The logs reveal the outcome of content reuse, not the service-side content inventory before each upload. A later identical benchmark can legitimately send a different physical byte count.
- `workspace.clean: all` removes the agent work directory, but it does not make the Azure artifact service a clean cache. These runs satisfy the clean-agent baseline only.
- Task wall time includes discovery, hashing, compression, manifest association, and upload. Effective Mbps is useful for end-to-end comparisons but must not be interpreted as direct link throughput, especially for tiny physical uploads.
- The overlap audit covers Azure `Publish artifacts` tasks visible in the build timelines. It cannot detect unrelated home-lab traffic or processes outside Azure Pipelines.
- One historical observation per configuration is not enough for a threshold. The first controlled benchmark should record the exact source checksum and artifact manifest size, run alone on one clean agent, and repeat the same artifact/candidate enough times to separate cold-content from warm-content behavior. Only after a candidate reduces physical bytes and complete task time should the same benchmark run with two agents concurrently.

The most useful first experiment is a Vagrant artifact from QEMU, VirtualBox, or VMware because existing Ubuntu and Windows runs both transferred more than 89% of those artifact bytes. The same experiment should retain a native artifact as a control, and the Windows 11 VirtualBox native case should be included as a second target because it exhibited the same near-full-transfer profile.
