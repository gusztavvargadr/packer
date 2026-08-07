# Sparse VirtualBox Vagrant packaging prototype

> PROTOTYPE — throw this code away after the packaging decision is captured.

This prototype answers one question: can a provisioned VirtualBox Vagrant build preserve a monolithic-sparse VMDK through box packaging instead of performing the normal compressed stream-optimized export?

Run it after a Packer VirtualBox OVF build completed with `skip_export = true` and `keep_registered = true`:

```console
ruby virtualbox_vagrant_sparse.rb representative <vagrant-artifact-directory> <architecture> <vagrant-transfer-helper>
```

The command reuses the registered-VM producer to emit a canonical OVF, monolithic-sparse VMDK, and NVRAM from the provisioned powered-off VM. It then passes exactly those files through Packer Vagrant plugin 1.1.6 using `null`, `artifice`, and the normal VirtualBox Vagrant post-processor. The shared Vagrant transfer helper verifies that the resulting box contains the unchanged canonical disk, declares the sparse OVF format, includes VirtualBox metadata for the requested architecture, and matches the generated checksum before the normal Vagrant boot test runs.
