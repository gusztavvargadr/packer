# Contributing

## Layout

`samples/<sample>` holds image options, Vagrantfiles, and Chef policies. `src/windows` and `src/ubuntu` hold the shared templates and provisioning. `src/artifact-transfer` holds the artifact handoff between jobs, and `src/vagrant-metadata` the box metadata that publication writes to the metadata host. `lib/gusztavvargadr/chef` is a submodule, and the native builds run its bootstrap scripts to install Cinc Client in the guest. `.azure-pipelines` holds the pipelines, and `docs/site` the public site. Docker, Development, and Kitchen each have a Windows and a Linux sample, such as `docker-windows` and `docker-linux`.

## Prerequisites

- The .NET SDK, Packer, Chef Workstation, Vagrant, and the provider. The native builds run `chef install` and `chef export` on the build machine.
- Ruby, and the archive tools the [artifact-transfer README](src/artifact-transfer/README.md) lists. Every image build uses both.
- rclone with an `r2` remote, for publication.
- Docker, for the site preview.
- On Apple-silicon hosts, see the site's [ARM64 page](https://packer.gusztavvargadr.me/arm64.html).

## Build

- Run `dotnet tool restore`, then `dotnet cake --configuration <sample>/<image>/<provider>/<native|vagrant> [--target <target>]`, from the repository root.
- The `<image>` values are the keys of `samples/<sample>/images.pkrvars.hcl`. Each configuration with a pipeline has `.azure-pipelines/<sample>/<image>/<provider>.yml`.
- `--showdescription` and `--tree` list the targets. For `build.cake` they need a `--configuration`, and any well-formed one works. `src/artifact-transfer/build.cake` needs none.
- The default target builds and tests the selected configuration only.
- A derived native or a Vagrant build needs its native source under `artifacts/` already, because Cake doesn't build it.
- `clean` removes all of `artifacts/`, not only the selected configuration.
- Ubuntu native builds take about 10 minutes and Vagrant builds under 5. Windows native builds take about an hour, Vagrant builds 5 to 10 minutes, and a CI build can pass 90 minutes. A long Windows build is not a reason to cancel it.

## Checks

- Image build or provisioning: the smallest affected configuration through Cake, including its `test`. A native `test` is empty, so native changes are proven by the derived or Vagrant build and boot test that consumes them.
- Artifact transfer: `dotnet cake src/artifact-transfer/build.cake`, plus the image builds that consume the changed provider. The `artifact-transfer.yml` pipeline covers Windows and Linux.
- Vagrant metadata: `dotnet cake src/vagrant-metadata/build.cake`.
- Cake task descriptions: `--showdescription` for both definitions, with any well-formed `--configuration` for `build.cake`, without running any target.
- HCL: `packer fmt -check src`.
- Ruby: `ruby -c <file>`, following `.rubocop.yml`.
- Pipeline YAML: parse it, as `ruby -e "require 'yaml'; YAML.load_file(ARGV[0])" <file>` does, and run the Cake targets it calls.
- The site: `docker compose --file docs/site/compose.yml up --build`, and read the changed pages.
- Docs: read the changed text and its links, and run `git diff --check`.

## Rules

- A derived native or Vagrant build reuses the same provider's native result, never another provider's.
- Image-specific options enter through the sample, not through copies of the shared templates.
- Packer variables hold external input only, and named locals hold everything derived from them.
- Build logic shared by local work and CI runs through Cake. Pipeline YAML only orchestrates, and an unavoidable inline script stays minimal with a comment saying why.
- The publication checksum describes the final compressed box.
- Publication uploads the payload to R2 under `<box>/<release-version>/<vagrant-provider>/<architecture>/vagrant.box`, never overwrites a released key, and has no HCP fallback. The upload and the metadata host write are not a transaction, so an upload can remain when the later metadata step fails.
- An alias points at its canonical box's entry for the same version, provider, and architecture, and has no payload of its own.
- A canonical box name states its real OS release and edition. Where an alias's edition differs by guest architecture, the site says so.
- Generated boxes and images stay in the ignored `artifacts/`. `packer_cache` and `.vagrant` are never committed.
- Secrets are never committed. They come from CI variable groups or the environment.

## Metadata host

`https://vagrant.gusztavvargadr.me` serves the Vagrant box metadata, so boxes resolve by name without HCP. It is a custom domain on the `vagrant` R2 bucket, which is separate from `r2:packer` and holds only metadata documents. Its objects are not released keys, so they can be rewritten and deleted.

### Contract

- Each box's document is the object `<author>/<box>` in `r2:vagrant`, served at `https://vagrant.gusztavvargadr.me/<author>/<box>` in Vagrant's box metadata format, as `application/json`.
- Vagrant 2.4.9 first requests `/api/v2/vagrant/<author>/<box>`, which the host doesn't serve, then `/<author>/<box>`. It reads a response as metadata only when it is `application/json`.
- A document lists only entries whose payload is on R2. Every download URL is the canonical entry's object under `https://images.packer.gusztavvargadr.me`.
- An alias entry carries its canonical entry's download URL and checksum directly, so it resolves to the canonical payload without `vagrantcloud.com` or HCP.
- Within a version and Vagrant provider, exactly one entry has `default_architecture` `true`. It is the image's configured default (`default_architecture` for the box, `alias_default_architecture` for the alias, both `amd64` unless set) when the version has that architecture, and otherwise the alphabetically first architecture.

A consumer selects the host with either of these settings. Vagrant with neither uses its default server, `https://vagrantcloud.com`:

- `VAGRANT_SERVER_URL=https://vagrant.gusztavvargadr.me` in the environment, with no Vagrantfile change. The `download` target sets it on the Packer process from the Cake argument `boxMetadataOrigin`, so the sample Vagrantfiles stay unchanged.
- `config.vm.box_server_url = "https://vagrant.gusztavvargadr.me"` in a Vagrantfile, where the environment variable would also redirect other publishers' boxes.

`VAGRANT_SERVER_URL` takes precedence over `config.vm.box_server_url` whenever it is set and not empty.

### Publication

- `publish` uploads the payload, then runs the [Vagrant metadata helper](src/vagrant-metadata/README.md) for the canonical box, and again for the alias when the image has one. The Packer variables `box_metadata_destination` and `box_metadata_snapshot` sit beside `box_artifact_destination` and `box_artifact_origin`.
- The helper reads the document and its ETag, merges the entry, and writes it back with `If-Match: "<etag>"`, or `If-None-Match: *` for a new document. R2 rejects the write when another publish changed the document in between, and the helper then rereads, merges again, and retries. Several publishes updating the same document at once lose no entry.
- An entry already present with the same URL and checksum leaves the document unwritten, and one with a different URL or checksum fails the publish. A rerun with the same values is therefore safe.
- A new document gets its description from the registry snapshot below. An existing document keeps its name, its description, and every other version as they are.
- A CI rerun of the publish job can't finish a failed metadata step, because `restore` rebuilds `vagrant.box` with new bytes and the `--immutable` upload refuses them. The publish log's `publishing` line prints the payload URL and checksum. Finish the step by hand from the repository root with those values, once for the box and once for its alias:

```
ruby src/vagrant-metadata/vagrant_metadata.rb publish --destination r2:vagrant --author gusztavvargadr --box <box> \
  --version <version> --provider <vagrant-provider> --architecture <architecture> --url <url> --checksum <checksum> \
  --default-architecture <architecture> --snapshot r2:packer/hcp-vagrant-registry/manifest-20261031T112055Z.json
```

### Registry snapshot and saved retired entries

HCP Vagrant takes no new boxes, and its operations end on 2026-12-31, so R2 keeps what only HCP stored. These objects in `r2:packer` are released keys:

- `hcp-vagrant-registry/manifest-20261031T112055Z.json` is a snapshot of the whole `gusztavvargadr` HCP Vagrant registry on 2026-10-31, in the format `vagrant-registry-export registry manifest` writes. It lists every box, version, provider, and architecture with its SHA-256 checksum, including the entries not saved, and is the only object under `hcp-vagrant-registry/`. Publication reads only a box's description from it, and only when it creates the box's document.
- The newest version of each retired canonical box, Vagrant provider, and guest architecture is saved under the usual `<box>/<release-version>/<vagrant-provider>/<architecture>/vagrant.box` key, 27 AMD64 entries in all. A box is retired when its page under `docs/site/images` marks it deprecated. A retired box gets no further release, so only HCP stored its newest payload.
- Each saved entry's release version is in the `yymm.0.0` form, mapped from its HCP version as the table below states. Each saved object has the SHA-256 the snapshot records for its HCP entry, and the metadata host lists it at its release version.
- The retired aliases `windows-10` and `sql-server` resolve to `windows-10-22h2-enterprise` and `sql-server-2019-developer-windows-server`, so their payloads are those saved canonical entries.

| Canonical box | HCP version | Release version | Vagrant providers |
| --- | --- | --- | --- |
| `windows-10-22h2-enterprise` | 2511.0.0 | 2511.0.0 | `hyperv`, `libvirt`, `virtualbox`, `vmware_desktop` |
| `windows-11-22h2-enterprise` | 2511.0.0 | 2511.0.0 | `hyperv`, `libvirt`, `virtualbox`, `vmware_desktop` |
| `visual-studio-2022-community-windows-10` | 2511.0.0 | 2511.0.0 | `hyperv`, `libvirt`, `virtualbox`, `vmware_desktop` |
| `windows-10-21h2-enterprise-ltsc` | 2509.0.0 | 2509.0.0 | `hyperv`, `virtualbox`, `vmware_desktop` |
| `windows-server-2019-standard` | 1809.0.2407 | 2407.0.0 | `hyperv`, `virtualbox`, `vmware_desktop` |
| `windows-server-2019-standard-core` | 1809.0.2407 | 2407.0.0 | `hyperv`, `virtualbox`, `vmware_desktop` |
| `sql-server-2019-developer-windows-server` | 2019.2102.2503 | 2503.0.0 | `hyperv`, `virtualbox`, `vmware_desktop` |
| `sql-server-2019-developer-windows-server-core` | 2019.2102.2503 | 2503.0.0 | `hyperv`, `virtualbox`, `vmware_desktop` |

## Retention

This policy decides which versions of the hosted Vagrant boxes stay and which go. The maintainer applies it by hand, and no tooling enforces it.

Each canonical box, Vagrant provider, and guest architecture is one combination, counted separately. The versions of a combination group by release month, the `yymm` their release version starts with, so every `2607.*` version is one month. The current release month is the `yymm` of the current release version, the default `version` argument in `build.cake`.

A combination keeps a release month when both of these hold, and every other release month is removed:

- It is one of the combination's latest two release months.
- It is no more than six months behind the current release month, so a current release month of 2607 keeps 2601, and one of 2610 does not.

These limit what is removed:

- A combination never loses its last version. Where every release month has aged out, the single newest version stays.
- An alias has no count of its own. Its metadata entry stays and goes with the canonical entry it references. A canonical entry stays where removing it would remove an alias's last version for that provider and guest architecture.
- Removing a whole box, or a whole provider or guest architecture from a box, is a separate action the maintainer names. This policy does not do it.

Removal works like this:

- Removing a version removes its metadata entry and its R2 file together.
- No metadata entry or alias is left pointing at a missing file, and the site shows only what remains.
- A removed release version is never published again.
- A `vagrant.box` file on R2 that has no metadata entry is removed. Every other R2 object stays.

Apply the policy only after a full new release has finished publishing. The maintainer approves the exact removals immediately before they happen.

## Conventions

- Every Cake task has a `.Description()`.
- HCL uses `packer fmt`. Ruby, YAML, and Cake use two-space indentation. Line endings follow `.gitattributes`.
- Sample and image folders use lowercase, hyphenated names, and provider files follow the existing pattern, such as `source.virtualbox.pkr.hcl`.
- Prose names guest architecture apart from host architecture, as in `Ubuntu ARM64 guest on a macOS ARM64 host`.
- One source line per Markdown paragraph or list item.

## Pipelines

- One Azure Pipeline per image and provider, plus `artifact-transfer.yml` for the artifact handoff. They run only when queued, never on push or pull request.
- The image pipelines run on self-hosted agents, and starting one may need the maintainer. `artifact-transfer.yml` runs on hosted Windows and Linux agents.
- A run on `master` also publishes. A run on a branch builds and tests only.
- `pages.yml` builds `docs/site` on a pull request that changes it, and deploys it from `master`.

## Pull requests

Say which samples, images, providers, and stages the change affects, and which checks ran.
