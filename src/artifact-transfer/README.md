# Artifact transfer

This module owns the internal prepare, reconstruct, and verify contract used to hand canonical image artifacts between clean Azure Pipeline jobs. Its supported representations are a Vagrant box produced by Packer Vagrant plugin 1.1.6 and a VirtualBox native image produced from a powered-off registered VM.

`canonicalize-hyperv-vagrant` corrects a packaged Hyper-V box before its normal boot test and final checksum are accepted. It requires exactly `Virtual Machines/box.xml` and one `.vmcx` directly under `Virtual Machines`, rejects unsafe or ambiguous archives, copies every retained raw-tar record byte-for-byte, independently verifies those record identities, atomically replaces `vagrant/vagrant.box`, and rewrites `checksum.sha256` for the corrected canonical bytes.

`prepare-vagrant` accepts the conventional artifact directory containing `vagrant/vagrant.box` and `checksum.sha256`. It first verifies the Packer checksum and archive safety, then atomically creates a transfer directory containing only the exact gzip-decoded `vagrant.raw.tar` and `manifest.json`.

`reconstruct-vagrant` accepts that two-file payload and atomically recreates the conventional artifact directory. Reconstruction validates the manifest, raw-tar identity and archive again, replays the recorded Packer tar-writer schedule, and accepts `vagrant/vagrant.box` only when its length and SHA-256 match the canonical identity. `verify-vagrant` independently checks the reconstructed directory and checksum before a downstream consumer runs.

The manifest pins every byte-affecting producer and compression dependency. Updating the Packer Vagrant plugin, pgzip, DEFLATE implementation, block size, compression level, gzip header, or named write schedule requires new byte-exact cross-host evidence and a new manifest schema or deliberately compatible contract.

Each operation reports its wall time, process user/system CPU, staging output size, and sampled peak disk consumption on the output volume. The manifest records when preparation started so downstream verification reports complete cross-job handoff time; Azure Pipeline Artifact task logs remain the source for physical bytes, task wall time, service retries, and task-version evidence.

`virtualbox_native.rb prepare-virtualbox-native` replaces Packer's registered VDI handoff with a canonical OVF, NVRAM, and monolithic-sparse VMDK. It preflights free space, stages atomically, restores the exact disk attachment on every path, removes only the Packer VM it owns, writes a versioned per-file manifest and checksum, and validates the OVF before publication. `verify-virtualbox-native` verifies the complete file set, every length and SHA-256, the positive VirtualBox `VMDK`/`dynamic default` medium contract, the sparse OVF declaration, and VirtualBox importability in a clean job.

`virtualbox_native.rb fixture-virtualbox-native` owns a temporary Packer VM and proves Packer cleanup, exact attachment restoration after an injected post-detachment failure, partial-output cleanup, canonical preparation, real import and start behavior, and final VM cleanup.

`virtualbox_native.rb produce-virtualbox-native` exposes the lower-level caller-owned VM boundary. It never unregisters or deletes that VM; only `prepare-virtualbox-native`, which discovers the VM created and handed off by the current Packer build, performs build-owned VM cleanup.
