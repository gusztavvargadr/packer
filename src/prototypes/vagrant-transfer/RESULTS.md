# Vagrant transfer prototype results

## Question

Can a real Packer-produced Vagrant box be transferred as an exact gzip-decoded raw tar stream plus a small manifest and reconstructed byte-for-byte on macOS, Linux, and Windows?

## Source artifact

The prototype used the published Windows 11 25H2 Enterprise Hyper-V box for release 2607.0.0. The source was 12,156,920,407 bytes with SHA-256 `bb044a55cf055b6b72db66f5842de73f276d0a034b57925b33405dfbf57caf41`.

Gzip decoding produced an 18,765,402,112-byte raw tar stream with SHA-256 `f0c6d5d1099a1b35e299fc71e7336eacc94945000aa36cf7e8519acc2befc46e`. The archive contained seven regular files, exactly one `.vmcx`, and exactly one `Virtual Machines/box.xml`; no unsafe path or entry type was accepted.

## Compression contract

The producing path was Packer Vagrant plugin 1.1.6 with `github.com/klauspost/pgzip` at `v0.0.0-20151221113845-47f36e165cec`, `github.com/klauspost/compress` 1.13.6, 500,000-byte blocks, default compression level `-1`, `runtime.GOMAXPROCS(-1)` parallelism, and gzip header `1f8b080000096e8800ff`.

A flat raw-tar write did not reconstruct the source. With the plugin 1.1.6 dependencies it produced 12,157,460,230 bytes and SHA-256 `72cf4b85835f1df00dff618094b6b9505a349f4b578fcac448cdbf67c4c481b4`; with plugin 1.1.7's pgzip 1.2.6 it produced 12,156,292,768 bytes and SHA-256 `625665f98aa3cbee50ea3e8a269e87c1ffc2ad3289f7388c222ed2f73967d7b4`.

The older pgzip library makes caller write boundaries byte-affecting. Replaying Packer's deterministic tar-writer schedule—512-byte headers, 32 KiB file writes, explicit entry padding, and two separate 512-byte trailer writes—reconstructed the source exactly.

## Cross-host results

| Host | Architecture | Parallelism | Reconstructed bytes | Reconstructed SHA-256 | Exact |
| --- | --- | ---: | ---: | --- | --- |
| Linux | ARM64 | 18 | 12,156,920,407 | `bb044a55cf055b6b72db66f5842de73f276d0a034b57925b33405dfbf57caf41` | Yes |
| macOS | ARM64 | 18 | 12,156,920,407 | `bb044a55cf055b6b72db66f5842de73f276d0a034b57925b33405dfbf57caf41` | Yes |
| Windows | AMD64 | 16 | 12,156,920,407 | `bb044a55cf055b6b72db66f5842de73f276d0a034b57925b33405dfbf57caf41` | Yes |

Different worker counts produced identical output, demonstrating that worker parallelism affects throughput but not the ordered compressed bytes under the fixed input and write schedule.

## Verdict

Use an exact raw tar transfer representation plus a small versioned manifest. The manifest must record source and raw-tar lengths and SHA-256 digests, the pinned pgzip and DEFLATE implementations, block size, compression level, parallelism policy, gzip header, and the Packer tar-write replay schedule. Reconstruction must validate the raw-tar checksum before accepting an output and must match the recorded source length and SHA-256.

Raw tar plus this manifest is sufficient. Do not introduce tar-split or custom chunk staging unless isolated Azure measurements show that the raw tar representation still transfers poorly.

The transfer contract applies to the canonical Vagrant box after the required pre-test packaging step removes exactly Hyper-V `Virtual Machines/box.xml`, verifies that a `.vmcx` remains, rejects unsafe archive entries, and establishes the bytes tested, hashed, transferred, and published. The lossless transfer representation does not itself remove or alter archive entries.
