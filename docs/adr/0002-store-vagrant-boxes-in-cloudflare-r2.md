---
status: accepted
---

# Store Vagrant boxes in Cloudflare R2

New Windows and Ubuntu Vagrant boxes use Cloudflare R2 as their box artifact origin regardless of artifact size, while HCP Vagrant Registry temporarily remains the catalog for release versions, providers, architectures, external download URLs, and SHA-256 checksums. Using one artifact-hosting path avoids size-dependent publication behavior and prepares payload hosting for the announced retirement of HCP Vagrant; replacing the registry metadata and discovery service is a separate decision.

R2 objects use `<canonical-box-name>/<release-version>/<vagrant-provider>/<architecture>/vagrant.box`. Publication copies only `vagrant.box` through the configured rclone destination, treats existing object keys as immutable, and has no direct-HCP fallback. Successful uploads may remain if later registry publication fails, no historical versions are migrated, and retention is deferred.

The rclone destination and public box origin are configurable, initially defaulting to `r2:packer` and the existing `r2.dev` endpoint. Moving production downloads to a custom domain is tracked by [#524](https://github.com/gusztavvargadr/packer/issues/524).

Alias boxes reference their canonical registry entries through the readable `vagrantcloud.com` download URL rather than storing duplicate artifacts.

Windows implementation is tracked by [#525](https://github.com/gusztavvargadr/packer/issues/525), and Ubuntu implementation is tracked by [#544](https://github.com/gusztavvargadr/packer/issues/544).
