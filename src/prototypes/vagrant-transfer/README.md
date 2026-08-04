# Vagrant transfer prototype

> PROTOTYPE — throw this code away after the packaging decision is captured.

This prototype answers one question: can a Packer-produced Vagrant box be transferred as its exact gzip-decoded raw tar stream plus a small manifest, then reconstructed byte-for-byte on macOS, Linux, and Windows?

It deliberately does not extract the archive. It validates every tar entry, records the source and raw-tar lengths and SHA-256 digests, and recompresses the unchanged tar bytes with the same pgzip implementation and settings used by the selected Packer Vagrant plugin. Reconstruction also replays Packer's tar-writer call boundaries because the pgzip version used by plugin 1.1.6 makes those boundaries byte-affecting.

Run a complete local round trip with one command:

```console
go run . roundtrip <source.box> <scratch-directory> <packer-vagrant-plugin-version>
```

To reconstruct on another host from an already-decoded transfer representation:

```console
go run . reconstruct-packer-writes <raw.tar> <manifest.json> <reconstructed.box>
```

The command prints the complete relevant state as JSON. A successful reconstruction exits zero only when the source length and SHA-256 match the manifest exactly.

See [RESULTS.md](RESULTS.md) for the captured macOS, Linux, and Windows evidence.
