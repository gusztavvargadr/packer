# Registered VirtualBox native artifact producer prototype

> PROTOTYPE — throw this code away after the producer decision is captured.

This prototype answers one question: can Packer VirtualBox plugin 1.1.5 skip its compressed export while a post-build producer safely emits the validated OVF plus monolithic-sparse VMDK native image before testing and hashing?

Run the complete local lifecycle fixture with one command:

```console
ruby virtualbox_native_producer.rb fixture <missing-output-directory>
```

The fixture uses a local ISO, exercises Packer with `skip_export` and `keep_registered`, verifies Packer's failure cleanup, injects a producer failure while the disk is detached, verifies disk restoration and partial-output cleanup, produces the canonical artifact, performs an OVF import dry-run, imports and starts the resulting machine, and deletes every temporary VM it owns. Set `FIXTURE_ISO` only when VirtualBox does not report a Default Guest Additions ISO.

For a representative Packer build that already completed with `skip_export = true` and `keep_registered = true`, run:

```console
ruby virtualbox_native_producer.rb produce <registered-vm-name> <missing-output-directory>
```

`produce` requires one powered-off primary disk on SATA port 0 device 0 and an NVRAM file. It clones the registered VDI directly to a monolithic-sparse VMDK, briefly detaches the source disk so `VBoxManage export` emits only OVF machine metadata plus NVRAM, restores and verifies the original attachment in an `ensure` block, adds the cloned disk to the OVF contract, performs an import dry-run, and atomically promotes the staging directory. It never unregisters a caller-owned VM.

The command prints each lifecycle state as JSON. The final manifest records the machine and disk identities, canonical file lengths and SHA-256 checksums, transformation timings, process CPU counters, and peak allocated staging bytes.

The throwaway Azure Pipeline hook runs the representative native-image build with `PKR_VAR_virtualbox_native_producer_prototype=true`, then invokes:

```console
ruby virtualbox_native_producer.rb representative <native-artifact-directory>
```

`representative` finds the one registered VM backed by the Packer output directory, produces the canonical artifact, unregisters the VM it owns, replaces the now-empty VDI output with the canonical `image/*.ovf` contract, removes the stale Packer manifest, and regenerates `checksum.sha256` over the canonical files before any consumer test or artifact publication.
