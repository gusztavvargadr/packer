---
status: accepted
---

# Store Windows Vagrant boxes in Cloudflare R2

Windows Vagrant boxes use Cloudflare R2 as their box artifact origin while HCP Vagrant Registry remains the catalog for release versions, providers, architectures, external download URLs, and SHA-256 checksums. This applies to every newly published Windows box regardless of size and remains the default even if direct uploads larger than 5 GiB become reliable again; Ubuntu boxes continue to use HCP-hosted artifacts.

R2 objects use `<canonical-box-name>/<release-version>/<vagrant-provider>/<architecture>/vagrant.box`. Publication copies only `vagrant.box` through the configured rclone destination, treats existing object keys as immutable, and has no direct-HCP fallback. Successful uploads may remain if later registry publication fails, no historical versions are migrated, and retention is deferred.

The rclone destination and public box origin are configurable, initially defaulting to `r2:packer` and the existing `r2.dev` endpoint. Moving production downloads to a custom domain is tracked by [#524](https://github.com/gusztavvargadr/packer/issues/524).

Alias boxes on both Windows and Ubuntu reference their canonical registry entries through the readable `vagrantcloud.com` download URL rather than storing duplicate artifacts.

Implementation is tracked by [#525](https://github.com/gusztavvargadr/packer/issues/525).
