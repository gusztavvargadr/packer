# Artifact transfer

This module owns the internal prepare, reconstruct, and verify contract used to hand canonical image artifacts between clean Azure Pipeline jobs. Its first supported representation is a Vagrant box produced by Packer Vagrant plugin 1.1.6.

`prepare-vagrant` accepts the conventional artifact directory containing `vagrant/vagrant.box` and `checksum.sha256`. It first verifies the Packer checksum and archive safety, then atomically creates a transfer directory containing only the exact gzip-decoded `vagrant.raw.tar` and `manifest.json`.

`reconstruct-vagrant` accepts that two-file payload and atomically recreates the conventional artifact directory. Reconstruction validates the manifest, raw-tar identity and archive again, replays the recorded Packer tar-writer schedule, and accepts `vagrant/vagrant.box` only when its length and SHA-256 match the canonical identity. `verify-vagrant` independently checks the reconstructed directory and checksum before a downstream consumer runs.

The manifest pins every byte-affecting producer and compression dependency. Updating the Packer Vagrant plugin, pgzip, DEFLATE implementation, block size, compression level, gzip header, or named write schedule requires new byte-exact cross-host evidence and a new manifest schema or deliberately compatible contract.

Each operation reports its wall time, process user/system CPU, staging output size, and sampled peak disk consumption on the output volume. The manifest records when preparation started so downstream verification reports complete cross-job handoff time; Azure Pipeline Artifact task logs remain the source for physical bytes, task wall time, service retries, and task-version evidence.
