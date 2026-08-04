# VirtualBox native artifact prototype

> PROTOTYPE — throw this code away after the artifact-layout decision is captured.

This prototype answers one question: can the current compressed VirtualBox OVF/VMDK native image become an uncompressed canonical native image before testing and hashing without changing the `image/*.ovf` import interface used by derived native and Vagrant builds?

The prototype clones the appliance's `streamOptimized` VMDK to a `monolithicSparse` VMDK, changes the OVF disk-format URI from `#streamOptimized` to `#sparse`, updates the OVF references to the cloned disk UUID, and retains the other appliance files unchanged. It records source and canonical file digests, logical and allocated bytes, VirtualBox medium metadata, transformation timings, and a successful `VBoxManage import --dry-run` in a sidecar manifest.

Prepare and verify a canonical native image with one command:

```console
ruby virtualbox_native.rb prepare <source-native-build-directory> <empty-canonical-native-build-directory>
```

Re-verify the canonical image after copying it to another host:

```console
ruby virtualbox_native.rb verify <canonical-native-build-directory>
```

The source directory may be either the complete downloaded `native-build` artifact or its `image` directory. The canonical directory always contains `image/*.ovf`, preserving the repository's existing import interface. Set `VBOXMANAGE` only when `VBoxManage` is not on `PATH`.

The commands print the complete relevant state as JSON. `verify` exits zero only when every canonical file matches the recorded length and SHA-256 and VirtualBox still accepts the OVF import contract.
