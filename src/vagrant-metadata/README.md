# Vagrant metadata

This module owns the Vagrant box metadata documents on the metadata host, `https://vagrant.gusztavvargadr.me`. Each document is the object `<author>/<box>` in the `r2:vagrant` bucket, served at `https://vagrant.gusztavvargadr.me/<author>/<box>` as `application/json`. The `vagrant-publish` stage of both OS templates runs it after the payload upload, once for the canonical box and once for the alias when the image has one. It uses only the Ruby standard library and rclone with an `r2:` remote.

## Command line

```
ruby vagrant_metadata.rb publish --destination r2:vagrant --author gusztavvargadr --box <box> \
  --version <version> --provider <vagrant-provider> --architecture <architecture> \
  --url <payload-url> --checksum <sha256> --default-architecture <architecture> \
  --snapshot r2:packer/hcp-vagrant-registry/manifest-20261031T112055Z.json
```

Every option is required. The command merges one entry into the document `<destination>/<author>/<box>` and logs the payload URL and checksum first, then the document it read (or `missing`), the document it writes, and each write's result. It exits 0 when the document holds the entry, and 1 with a message on any error.

## Document rules

- **Missing document:** the command creates it with `name` `<author>/<box>`, the box's description from the registry snapshot, and one version holding the entry. A box missing from the snapshot, or with an empty description there, gets no description. The snapshot is read only when a document is created, and a snapshot that can't be read fails the publish without writing.
- **Existing document:** its name, description, and every other version stay exactly as they are.
- **Missing version:** the command adds it with `status` `active`.
- **Entry:** the version, the Vagrant provider as `name`, `url`, `checksum`, `checksum_type` `SHA256`, `architecture`, and `default_architecture`. An alias entry carries its canonical entry's URL and checksum.
- **Entry already present:** an entry with the same version, provider, and architecture and the same URL and checksum leaves the document unwritten. A different URL or checksum fails the publish without writing.
- **Default architecture:** within the published version and provider, exactly one entry has `default_architecture` `true`: the one with `--default-architecture` when the version has it, otherwise the alphabetically first architecture. Other versions' flags are left alone.
- **Ordering:** versions are newest first by numeric segments, so `2610.10.0` comes before `2610.9.0`. Providers are ordered by name, then architecture.

## Conditional write

The command reads the document's MD5 hash with `rclone lsjson --stat --hash --files-only`, then its body with `rclone cat`, and rereads when the body doesn't match the hash. For R2, that hash is the object's ETag. `lsjson` prints `null` for a missing document.

It writes with `rclone rcat` and `--header-upload "If-Match: \"<etag>\""`, or `--header-upload "If-None-Match: *"` for a new document, so R2 rejects the write with `412 Precondition Failed` when another publish changed the document in between. On a rejection the command waits 1 to 4 seconds, rereads, merges again, and retries, up to 5 attempts. Any other rclone failure stops the publish at once with rclone's error.

When R2 commits a write but its response is lost, the retry finds the entry already present and stops.

## Finishing a failed publish

The payload upload and the metadata update are not a transaction. A CI rerun of the publish job can't finish a failed metadata step, because `restore` rebuilds `vagrant.box` with new bytes, and the `--immutable` upload refuses them.

Instead, rerun the command by hand with the values the failed publish logged on its `publishing` line, once for the box and once for its alias. The alias uses the canonical box's URL and checksum, and the image's alias default architecture. An entry that's already present is skipped, and a missing one is written.

## Tests

`dotnet cake build.cake` runs `vagrant_metadata_test.rb`, which tests merging, conditional publication, and the command line against a fake store and a stubbed rclone.
