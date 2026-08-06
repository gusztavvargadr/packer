# Repository Guidelines

## Project Structure & Module Organization

`src/windows/` and `src/ubuntu/` contain the shared Packer HCL templates, boot configuration, Chef cookbooks, and Vagrant definitions for each guest operating system. `samples/<sample>/` supplies a consumer-facing `Vagrantfile`, `Policyfile.rb`, and `images.pkrvars.hcl`; add image-specific options there rather than duplicating shared sources. Azure Pipelines definitions mirror those samples under `.azure-pipelines/`. Reusable Chef assets live in `lib/gusztavvargadr/chef/`. Repository guidance and architectural decisions live directly under `docs/`, while the public Jekyll site and release posts live under `docs/site/`. Generated boxes or images belong in the ignored `artifacts/` directory.

## Build, Test, and Development Commands

- `dotnet tool restore` installs the repository-pinned Cake 4.0 tool.
- `packer fmt -check src` checks HCL formatting before review; use `packer fmt src` to apply it.
- `docker compose --file docs/site/compose.yml up --build` builds and serves the public Jekyll site at `http://localhost:4000` for documentation verification.
- `dotnet cake --configuration windows-11/25h2-enterprise/virtualbox/native --target init` initializes required Packer plugins.
- `dotnet cake --configuration <sample>/<image>/<provider>/<build>` runs the default `init`, `restore`, `build`, and `test` pipeline.
- `dotnet cake --configuration <...> --target clean` removes generated artifacts.

Valid providers include `virtualbox`, `vmware`, `hyperv`, and `qemu`; builds require the matching local virtualization stack. Ubuntu native builds typically take about 10 minutes from an ISO and less when derived, while Ubuntu Vagrant builds usually take under 5 minutes. Windows native ISO builds usually take about an hour and can be faster when derived; Windows Vagrant builds usually take 5–10 minutes.

When a container command cannot reach the local Docker daemon from the sandbox, retry that same command outside the sandbox before installing or compiling alternative tooling.

## Coding Style & Naming Conventions

Run `packer fmt` for HCL. Use Packer input variables only to capture external input; assign them to descriptively named locals and use locals everywhere else, including for all derived values. Use two-space indentation in Ruby, YAML, and Cake files, and follow existing PowerShell and shell conventions. Ruby style is governed by `.rubocop.yml`; generated and vendored `lib/` content is excluded. Do not hard-wrap prose in Markdown files or GitHub issue and pull request content; keep each paragraph or list item on one source line and let the renderer wrap it. Preserve repository line endings: LF for shell scripts and CRLF for PowerShell. Use lowercase, hyphenated sample and image-variant directories (for example, `ubuntu-server` and `25h2-enterprise`), and keep provider-specific files named consistently, such as `source.virtualbox.pkr.hcl`.

## Testing Guidelines

There is no standalone unit-test suite or typechecking step. When a generic skill asks for typechecking, individual test files, or a full test suite, follow these repository-specific checks instead. For build changes, validation is performed by Packer’s `test` build stage for a complete configuration tuple; test the smallest affected sample/provider combination locally and rely on the corresponding Azure Pipeline matrix for provider coverage. For documentation-only changes, run the relevant format or syntax checks for the changed artifacts. Never commit `packer_cache`, `.vagrant`, or `artifacts`.

## Build and log context hygiene

Packer, Cake, Vagrant, Docker, and virtualization builds are transcript-heavy. After implementation, delegate each independent configuration tuple or log-analysis pass to one non-editing build worker when possible.

Save complete build output to a unique temporary or ignored log file. Report only the configuration tuple, command, duration, exit status, first failing stage, a bounded relevant excerpt, and the log path. Do not paste complete logs into the main task.

Run quick formatting and syntax checks directly in the main task. Keep complete image builds, repeated polling, and broad failure-log analysis outside the main task unless they are inseparable from the current edit.

## Azure home-lab build agents

Azure Pipelines uses three physical home-lab hosts. The Linux AMD64 host supports QEMU, VirtualBox, and VMware; the Windows AMD64 host supports Hyper-V, VirtualBox, and VMware; and the macOS ARM64 host supports VirtualBox and VMware. Each host runs only one provider-specific Azure agent service and one build at a time. Different agent names on the same physical host do not provide additional concurrency. One build may run concurrently on each physical host when their required providers and architectures differ.

Provider changes require manual intervention: ask the user to stop the current agent service and start the required provider-specific service, then wait for confirmation before queueing. Do not change agent services or install host tools without explicit authorization.

Queue builds against an exact branch and commit. For pipelines without runtime parameters, use `az pipelines build queue`. Because that command cannot supply YAML template parameters, parameterized builds must use the Build API:

`az devops invoke --organization https://dev.azure.com/gusztavvargadr --area build --resource builds --route-parameters project=packer --api-version 7.1 --http-method POST --in-file <request.json>`

The request must include `definition.id`, `sourceBranch`, `sourceVersion`, and any `templateParameters`. Before queueing, check both `inProgress` and `notStarted` builds for the physical host. Run ordered build sequences serially and queue the next build only after the previous build succeeded with a clean timeline. Windows image builds may take more than 90 minutes; duration alone is not a reason to cancel them. Stop automation on any failure or user request. Stopping a polling controller does not cancel an already-running Azure build.

## Commit & Pull Request Guidelines

Recent commits use short, imperative, title-cased summaries such as `Update for 2607 - Core (#519)`. Keep each commit focused and include the PR number when merged. Pull requests should describe affected samples, images, providers, and build stages; link relevant issues; report commands or pipeline jobs run; and include screenshots only for documentation or visible guest-image changes.

## Security & Configuration

Do not commit cloud credentials, Vagrant Cloud tokens, HCP secrets, product keys, or generated variable files containing secrets. Publishing credentials belong in CI variable groups or local environment variables.

## Agent skills

### Issue tracker

Issues and PRDs are tracked in this repository’s GitHub Issues. See `docs/agents/issue-tracker.md`.

### Triage labels

Use the canonical `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, and `wontfix` labels. See `docs/agents/triage-labels.md`.

### Domain docs

This is a single-context repository using root `CONTEXT.md` and `docs/adr/`. See `docs/agents/domain.md`.
