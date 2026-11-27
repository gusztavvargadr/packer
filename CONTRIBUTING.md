# Contributing

## Layout

`samples/<sample>` holds image options, Vagrantfiles, and Chef policies. `src/windows` and `src/ubuntu` hold the shared templates and provisioning. `src/artifact-transfer` holds the artifact handoff between jobs. `lib/gusztavvargadr/chef` is a submodule. `.azure-pipelines` holds the pipelines, and `docs/site` the public site. Docker, Development, and Kitchen each have a Windows and a Linux sample, such as `docker-windows` and `docker-linux`.

## Prerequisites

- The .NET SDK, Packer, Chef Workstation, Vagrant, and the provider. The native builds run `chef install` and `chef export` on the build machine.
- Ruby, and the archive tools the [artifact-transfer README](src/artifact-transfer/README.md) lists. Every image build uses both.
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
- Publication uploads the payload to R2 under `<box>/<release-version>/<vagrant-provider>/<architecture>/vagrant.box`, never overwrites a released key, and has no HCP fallback. The upload and the registry write are not a transaction, so an upload can remain when the later registry step fails.
- An alias points at its canonical box's entry for the same version, provider, and architecture, and has no payload of its own.
- A canonical box name states its real OS release and edition. Where an alias's edition differs by guest architecture, the site says so.
- Generated boxes and images stay in the ignored `artifacts/`. `packer_cache` and `.vagrant` are never committed.
- Secrets are never committed. They come from CI variable groups or the environment.

## Retention

This policy decides which versions of the hosted Vagrant boxes stay and which go. The maintainer applies it by hand, and no tooling enforces it.

Each canonical box, Vagrant provider, and guest architecture is one combination, counted separately. The versions of a combination group by release month, the `yymm` their release version starts with, so every `2607.*` version is one month. The current release month is the `yymm` of the current release version, the default `version` argument in `build.cake`.

A combination keeps a release month when both of these hold, and every other release month is removed:

- It is one of the combination's latest two release months.
- It is no more than six months behind the current release month, so a current release month of 2607 keeps 2601, and one of 2610 does not.

These limit what is removed:

- A combination never loses its last version. Where every release month has aged out, the single newest version stays.
- An alias has no count of its own. Its registry entry stays and goes with the canonical entry it references. A canonical entry stays where removing it would remove an alias's last version for that provider and guest architecture.
- Removing a whole box, or a whole provider or guest architecture from a box, is a separate action the maintainer names. This policy does not do it.

Removal works like this:

- Removing a version removes its registry entry and its R2 file together.
- No registry entry or alias is left pointing at a missing file, and the site shows only what remains.
- A removed release version is never published again.
- A `vagrant.box` file on R2 that has no registry entry is removed. Every other R2 object stays.

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
