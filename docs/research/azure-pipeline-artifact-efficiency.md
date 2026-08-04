# Azure Pipeline Artifact upload efficiency

## Question

How do the Azure Pipelines artifact tasks used by this repository chunk, deduplicate, compress, cache, upload, and download content; what is the scope and lifetime of reuse; how do already-compressed or high-entropy files affect physical transfer; and which task log metrics reliably measure bytes and time?

## Conclusion

Azure Pipeline Artifacts already implement a service-backed, content-addressed transfer: the agent builds a deduplication manifest, splits file bytes into content-defined chunks, identifies content already present in the Azure DevOps blob store, compresses and uploads the missing content, and associates the manifest with the pipeline run. Microsoft describes the outcome as uploading only “net-new content” on repeated builds, and the agent source confirms that `PublishPipelineArtifact` delegates to `DedupManifestArtifactClient.PublishAsync` before associating the returned manifest and its content metadata with the build ([Microsoft Azure DevOps Blog](https://devblogs.microsoft.com/devops/caching-and-faster-artifacts-in-azure-pipelines/), [agent upload implementation](https://github.com/microsoft/azure-pipelines-agent/blob/891d3e106d49e7180d0e1b7d4d0000f2b3f27f0b/src/Agent.Plugins/Artifact/PipelineArtifactServer.cs#L35-L105)). This deduplication is service-side and therefore still works when this repository uses `workspace.clean: all`; it does not require a retained home-lab workspace.

The user's compressed-artifact theory is mechanically sound, but it remains a hypothesis for each concrete file until measured. Pipeline Artifact chunking sees the stored file's bytes, not the uncompressed semantic content inside it. A precompressed or otherwise high-entropy stream usually has little further compression available, and even a small input or metadata change can change a long span of compressed output, eliminating chunk matches that would have existed among unpacked member files. The expected signature is low `Deduplication Saved`, low `Compression Saved`, and `Physical Content Uploaded` close to `Total Content`; a controlled benchmark must establish whether each artifact actually has that signature.

For this repository, `Physical Content Uploaded` plus task wall time are the best built-in upload indicators, but they are not a complete network measurement. The counter is a content-payload statistic and is not documented as including HTTP headers, manifest traffic, retries, TLS framing, or other protocol overhead. Benchmark runs should therefore capture the upload task's start/end timestamps and agent/NIC transmitted bytes as the primary measurements, retaining the task counters to explain deduplication and compression.

## Publish and download mechanics

The YAML `publish` shortcut invokes `PublishPipelineArtifact@1`; that task accepts exactly one file or directory path and dispatches to the agent's Pipeline Artifact plugin ([official task documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/publish-pipeline-artifact-v1?view=azure-pipelines), [task definition](https://github.com/microsoft/azure-pipelines-tasks/blob/c171dabe2ccd0c70c1118eaedda5fe9e9df38932/Tasks/PublishPipelineArtifactV1/task.json#L20-L40), [plugin dispatch](https://github.com/microsoft/azure-pipelines-tasks/blob/c171dabe2ccd0c70c1118eaedda5fe9e9df38932/Tasks/PublishPipelineArtifactV1/task.json#L93-L97)). The plugin obtains server-provided blob-store settings, creates a dedup manifest client, calls `PublishAsync`, and records the manifest ID, logical content size, hash type, and blob-store domain on the build artifact ([agent upload implementation](https://github.com/microsoft/azure-pipelines-agent/blob/891d3e106d49e7180d0e1b7d4d0000f2b3f27f0b/src/Agent.Plugins/Artifact/PipelineArtifactServer.cs#L45-L105)).

The public BuildXL implementation used by the agent describes chunking based on the Windows deduplication algorithm. It uses a 16-byte sliding Rabin hash and content-derived cut points, rather than cutting every file at fixed offsets ([Rabin chunker](https://github.com/microsoft/BuildXL/blob/79247e4811e7693e3e18f18895cb875c32b76714/Public/Src/Cache/ContentStore/Hashing/Chunking/RegressionChunking.cs#L60-L117)). The available dedup hash types have 64 KiB or 1 MiB average chunks, and each configuration uses half the average as its minimum and twice the average as its maximum ([hash type sizes](https://github.com/microsoft/BuildXL/blob/79247e4811e7693e3e18f18895cb875c32b76714/Public/Src/Cache/ContentStore/Hashing/HashTypeExtensions.cs#L32-L45), [chunk-size bounds](https://github.com/microsoft/BuildXL/blob/79247e4811e7693e3e18f18895cb875c32b76714/Public/Src/Cache/ContentStore/Hashing/ChunkerConfiguration.cs#L64-L77)). Each chunk is hashed from its raw byte range with SHA-512 truncated to 32 bytes ([managed chunk hashing](https://github.com/microsoft/BuildXL/blob/79247e4811e7693e3e18f18895cb875c32b76714/Public/Src/Cache/ContentStore/Hashing/ManagedChunker.cs#L93-L111)). Content-defined boundaries allow unchanged regions of ordinary files to realign after inserted or removed bytes; they do not recover the uncompressed structure hidden inside an archive or compressed disk stream.

The actual hash type is selected from service settings and emitted in the task log as `Hashtype`; the agent then constructs the client with that hash type ([client construction](https://github.com/microsoft/azure-pipelines-agent/blob/891d3e106d49e7180d0e1b7d4d0000f2b3f27f0b/src/Microsoft.VisualStudio.Services.Agent/Blob/DedupManifestArtifactClientFactory.cs#L126-L146)). Do not assume that every run uses the same average chunk size: record `Hashtype` in every benchmark.

Downloads reverse this process from the manifest. `DownloadPipelineArtifact@2` selects a current or specific run and artifact, optionally filters files with minimatch patterns, and sends the manifest ID, destination, and patterns to `DedupManifestArtifactClient.DownloadAsync` ([official download documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/artifacts/pipeline-artifacts?view=azure-devops#download-artifacts), [task pattern input](https://github.com/microsoft/azure-pipelines-tasks/blob/c171dabe2ccd0c70c1118eaedda5fe9e9df38932/Tasks/DownloadPipelineArtifactV2/task.json#L154-L189), [agent download implementation](https://github.com/microsoft/azure-pipelines-agent/blob/891d3e106d49e7180d0e1b7d4d0000f2b3f27f0b/src/Agent.Plugins/Artifact/PipelineArtifactProvider.cs#L57-L77)). Filtering can reduce a download when a consumer needs only part of a multi-file artifact, but it cannot reduce a transfer when the required payload is one indivisible file.

## Deduplication, compression, and high-entropy content

The operational pipeline is best understood as four reductions:

1. `Total Content` is the logical byte size of the selected artifact files.
2. Chunk hashes let the service reject content it already has in the applicable blob-store domain; the remaining uncompressed chunk bytes are `Logical Content Uploaded`.
3. The client compresses those missing bytes; the resulting content payload is `Physical Content Uploaded`.
4. Manifests, dedup nodes, HTTP/TLS overhead, retries, and task setup add transfer and wall-time costs that the content counters do not fully describe.

The first three steps are consistent with Microsoft's “net-new content” description and with the task's reported arithmetic. Microsoft has not published the artifact client's compression codec, compression level, exact counter specification, or wire-accounting boundary in the official documentation or open agent source. Treat the equations below as an operational interpretation to validate against each log, not a protocol contract:

```text
Deduplication Saved ~= Total Content - Logical Content Uploaded
Compression Saved   ~= Logical Content Uploaded - Physical Content Uploaded
```

The implications for candidate representations are:

- Identical chunks can be reused regardless of file name or source workspace because identity comes from content hashes, provided the upload uses a compatible hash type and blob-store domain.
- Raw sparse/zero-filled or mostly stable disk content is favorable: repeated chunks can deduplicate and low-entropy missing chunks can compress.
- Already-compressed or encrypted content is unfavorable for compression because its byte stream is intentionally high entropy.
- Repacking a compressed container can be unfavorable for deduplication even when most logical members are unchanged, because timestamps, ordering, headers, compressor settings, or a changed member can alter a broad span of the compressed byte stream.
- Transferring a stable unpacked or normalized representation can expose member-level and raw-data redundancy, but that is a benchmark candidate rather than a conclusion. It must include transform time, upload, download, reconstruction, temporary disk use, and byte-for-byte checksum verification of the original tested artifact.

## Reuse and caching scope

Microsoft explicitly says Pipeline Artifacts reuse server content across repeated builds, so reuse is broader than one job or one local workspace ([Microsoft Azure DevOps Blog](https://devblogs.microsoft.com/devops/caching-and-faster-artifacts-in-azure-pipelines/)). The agent records and later reuses a `DomainId` with each manifest and creates the download client for that domain ([upload domain selection](https://github.com/microsoft/azure-pipelines-agent/blob/891d3e106d49e7180d0e1b7d4d0000f2b3f27f0b/src/Agent.Plugins/Artifact/PipelineArtifactServer.cs#L45-L65), [download domain selection](https://github.com/microsoft/azure-pipelines-agent/blob/891d3e106d49e7180d0e1b7d4d0000f2b3f27f0b/src/Agent.Plugins/Artifact/PipelineArtifactProvider.cs#L40-L56)). Therefore, reuse cannot cross incompatible content domains or hash types.

Microsoft does not document whether the effective content domain is organization-, project-, repository-, or another service-defined scope, nor how long an unreferenced chunk remains available for future deduplication. Run retention governs artifact availability: deleting a run removes its pipeline and build artifacts ([retention documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/policies/retention?view=azure-devops#what-parts-of-the-run-get-deleted)), but the documentation does not specify deduplicated chunk garbage-collection timing when chunks are shared with other retained manifests. A warm service-side dedup state is useful observed behavior, not a persistence guarantee; experiments must record which preceding artifacts still exist and should include both cold-ish and repeated uploads where feasible.

Self-hosted workspace retention is independent. Azure Pipelines documents `workspace.clean: all` as deleting the entire pipeline workspace before a self-hosted job, while also warning that jobs can be routed to different eligible agents ([job workspace documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/phases?view=azure-devops#workspace)). Keeping this repository's clean baseline removes local-file reuse but does not disable service-side upload deduplication. The download log's `Local Caching Saved` counter may reveal locally satisfied content, but Microsoft does not publicly specify that cache's lookup and lifetime; under `workspace.clean: all`, it should not be treated as an optimization dependency.

## Reading task logs

| Log field | Operational meaning | Use in benchmarks |
| --- | --- | --- |
| `Total Content` | Logical bytes represented by the selected files. | Artifact-size denominator; not bytes sent. |
| `Logical Content Uploaded` | Uncompressed bytes of chunks that were not eliminated by service-side deduplication. | Diagnose dedup effectiveness. |
| `Physical Content Uploaded` | Compressed content payload uploaded for missing chunks. | Best built-in proxy for uplink bytes, but not complete wire bytes. |
| `Compression Saved` | Difference between missing logical content and its compressed payload. | Diagnose client compression effectiveness. |
| `Deduplication Saved` | Logical content eliminated because matching content already existed. | Diagnose service-side reuse. |
| `Number of Chunks Uploaded` | Count of uploaded content chunks. | Explain request/chunk overhead and compare hash-type behavior. |
| `Physical Content Downloaded` | Compressed content payload fetched for reconstruction. | Best built-in download-byte proxy. |
| `Local Caching Saved` | Content not fetched because it was already available locally according to the client. | Verify that a clean baseline is not benefiting from local reuse. |
| `Chunks Downloaded` / `Nodes Downloaded` | Content and manifest-node object counts fetched. | Explain overhead; not byte measures. |

Use the unrounded values if debug telemetry exposes them; otherwise preserve the displayed values and their units. Use the task's `Starting` and `Finishing` timestamps for wall time, not only progress-line intervals. Calculate effective payload throughput as `Physical Content Uploaded / task wall time`, and separately record operating-system transmitted bytes over the same interval. The OS counter is essential for detecting retries, manifest overhead, task traffic not represented by `Physical Content Uploaded`, and contention when two home-lab agents share the 1 Gbps uplink.

## Supported levers relevant to this repository

### Supported and documented

- Keep `workspace.clean: all` for the agreed clean-agent baseline. It makes runs replaceable and separates service-side deduplication from accidental local reuse ([workspace cleaning](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/phases?view=azure-devops#workspace)).
- Publish only necessary files. `.artifactignore` is the supported way to exclude files below the publish target, although it cannot help when the required artifact is a single opaque file ([`.artifactignore` documentation](https://learn.microsoft.com/en-us/azure/devops/artifacts/reference/artifactignore?view=azure-devops)).
- Restrict downloads with the task's `artifact` and `patterns` inputs when a consumer needs only a subset ([download artifact selection](https://learn.microsoft.com/en-us/azure/devops/pipelines/artifacts/pipeline-artifacts?view=azure-devops#artifacts-selection)).
- Preserve cross-job and cross-run chaining with current/specific pipeline artifact downloads or pipeline resources. The download task supports a specific pipeline, branch, and run selection ([download task definition](https://github.com/microsoft/azure-pipelines-tasks/blob/c171dabe2ccd0c70c1118eaedda5fe9e9df38932/Tasks/DownloadPipelineArtifactV2/task.json#L24-L120)).
- Change the handoff location from Azure Pipelines to an agent-accessible file share with `publishLocation: filepath`. The supported task inputs include parallel copy and a parallel count from 1 to 128; publishing to a file share from Linux or macOS agents is not supported ([official task documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/publish-pipeline-artifact-v1?view=azure-pipelines), [task inputs](https://github.com/microsoft/azure-pipelines-tasks/blob/c171dabe2ccd0c70c1118eaedda5fe9e9df38932/Tasks/PublishPipelineArtifactV1/task.json#L42-L82)). A local-network file share could avoid the constrained Internet uplink for compatible producers and consumers, but it changes availability, cleanup, security, and external-agent reachability and therefore requires its own measured design.
- Change job placement and topology. Keeping producer and consumer work in one job avoids an artifact handoff, but separate jobs have no supported guarantee of landing on the same self-hosted agent, and this repository intentionally preserves native/Vagrant separation. Placing the terminal Vagrant publication job on an external agent improves that agent's downstream public upload and moves the Pipeline Artifact download off the home uplink; it does not eliminate the home build agent's initial Pipeline Artifact upload.

There is no documented `PublishPipelineArtifact@1` input to select a compression codec or level, disable compression, set chunk size, cap Azure blob-store concurrency, or pin the deduplication domain. Representation changes and topology changes are consequently the main supported experimental surface for reducing bytes.

### Visible in source but not a supported task contract

The open agent recognizes `AZURE_PIPELINES_DEDUP_PARALLELISM`, preferring it over server-provided parallelism, and otherwise currently falls back to an internal default of 192 ([parallelism selection](https://github.com/microsoft/azure-pipelines-agent/blob/891d3e106d49e7180d0e1b7d4d0000f2b3f27f0b/src/Microsoft.VisualStudio.Services.Agent/Blob/DedupManifestArtifactClientFactory.cs#L209-L239), [current default](https://github.com/microsoft/azure-pipelines-agent/blob/891d3e106d49e7180d0e1b7d4d0000f2b3f27f0b/src/Microsoft.VisualStudio.Services.Agent/Blob/DedupManifestArtifactClientFactory.cs#L76-L80)). This may affect single-agent throughput or fairness under concurrent uploads, but it cannot improve deduplication or compression ratios. It is not in the published task inputs, so test it only as an explicitly experimental agent-version-specific knob.

The agent source also contains `AGENT_ENABLE_PIPELINEARTIFACT_LARGE_CHUNK_SIZE` and `OVERRIDE_PIPELINE_ARTIFACT_CHUNKSIZE`; both default to disabled/empty and are absent from official task documentation ([knob definitions](https://github.com/microsoft/azure-pipelines-agent/blob/891d3e106d49e7180d0e1b7d4d0000f2b3f27f0b/src/Agent.Sdk/Knob/AgentKnobs.cs#L448-L460), [client selection logic](https://github.com/microsoft/azure-pipelines-agent/blob/891d3e106d49e7180d0e1b7d4d0000f2b3f27f0b/src/Microsoft.VisualStudio.Services.Agent/Blob/BlobstoreClientSettings.cs#L86-L130)). These are implementation knobs, not stable configuration API. They can help a disposable diagnostic isolate chunk-size sensitivity if the current agent honors them, but the production specification should not depend on them without Microsoft support confirmation.

## Measurement consequences

The first controlled experiment should retain the current `workspace.clean: all` baseline and collect, for every upload and paired download: artifact checksum and logical size, task version, agent version, `Hashtype`, blob-store `DomainId`, all upload/download statistic fields, task wall time, transform/reconstruction wall time, agent CPU and peak temporary disk, and OS network bytes. The first comparison should run on one otherwise-idle home-lab agent; only a successful representation or topology candidate should advance to the agreed two-agent contention test.

Each representation experiment needs two upload conditions: a first upload after documenting the available retained artifacts, and an immediate repeat with identical or minimally changed content. The first measures compression and available historical reuse; the repeat proves the attainable dedup ceiling. A candidate wins only when the complete handoff—transformation, physical upload, downstream download, reconstruction, and checksum verification—reduces home-uplink bytes and wall time without changing the tested artifact.

## Known limits of this research

- The `DedupManifestArtifactClient` and blob-store service implementations that perform missing-chunk discovery, compression, transfer, and statistic formatting are distributed as Microsoft libraries but are not open in the agent repository. The public sources establish the call path, chunking implementation, settings, and manifest association, not the compression codec or exact wire accounting.
- Microsoft documents artifact/run retention but not shared dedup-chunk garbage collection or the exact tenant boundary represented by `DomainId`.
- This report deliberately does not measure the referenced builds and does not analyze provider disk or container formats; those are separate evidence tickets.
