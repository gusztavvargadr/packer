# Engineering

The repository uses Packer HCL and Chef to build Windows and Ubuntu environments, with Vagrant for box consumption and boot validation. The repository-pinned Cake tool is the shared interface for local development and CI.

## Environment

The [.NET tool manifest](../.config/dotnet-tools.json) pins Cake 4.0.0. Packer's required version and plugins are declared in the shared OS HCL definitions. Image builds also need Chef, Vagrant and the selected provider's local virtualization stack. The [ARM64 requirements](site/arm64.md) describe the supported Mac hosts and provider combinations.

Artifact transfer requires Ruby, the platform libarchive tar (`tar` on Windows and macOS, `bsdtar` on Linux), and `pigz`. Publication additionally requires the configured rclone destination and registry credentials. Archive-tool validation reports installed versions without installing host archive tools; Packer initialization restores the declared Packer plugins.

## Operations

Run commands from the repository root. Restore the pinned tool before using the Cake entry point:

```shell
dotnet tool restore
```

The [root build definition](../build.cake) and [artifact-transfer definition](../src/artifact-transfer/build.cake) describe what they offer. Ask them for descriptions and dependency graphs rather than maintaining a prose list of targets:

```shell
dotnet cake --configuration windows-11/25h2-enterprise/virtualbox/native --showdescription
dotnet cake --configuration windows-11/25h2-enterprise/virtualbox/native --tree
dotnet cake src/artifact-transfer/build.cake --showdescription
dotnet cake src/artifact-transfer/build.cake --tree
```

Every repository-owned Cake task MUST have a meaningful `.Description()` visible through `--showdescription` without running its actions:

```csharp
Task("build")
  .Description("Build the selected native image or package its native result as a Vagrant box.")
  .Does(() => {
    PackerBuild("build");
  });
```

Build selection uses `<sample>/<image>/<provider>/<build>`. Providers include `virtualbox`, `vmware`, `hyperv`, and `qemu`; the supported combinations are documented per image. The build field is `native` or `vagrant`. A full local invocation is:

```shell
dotnet cake --configuration windows-11/25h2-enterprise/virtualbox/native
```

Native ancestors MUST already be available for derived and Vagrant builds; Cake does not build them recursively. Select a single operation with `--target` as described by the definitions. The `clean` operation removes the shared `artifacts/` directory across configurations, not just the selected tuple.

Ubuntu native ISO builds typically take about 10 minutes and derived builds less; Ubuntu Vagrant builds are usually under 5 minutes. Windows native ISO builds typically take about an hour and derived builds can be faster; Windows Vagrant builds usually take 5–10 minutes. Windows CI builds can exceed 90 minutes, which alone is not a reason to cancel them.

## Checks

There is no repository-wide standalone unit-test or typechecking suite. The checks depend on the change:

| Change | Required validation |
| --- | --- |
| Image build or provisioning behavior | Run the smallest affected complete sample/image/provider/build configuration through Cake and its Packer `test` stage. Use the corresponding Azure Pipeline matrix for provider coverage. Native test stages are empty; native reuse and guest compatibility require the consuming derived or Vagrant build and boot test. |
| Artifact-transfer behavior | Run `dotnet cake src/artifact-transfer/build.cake` for archive preparation, restoration, and checksum coverage. Exercise affected provider contracts through their consuming image builds; use the dedicated Azure validation for Windows and Linux archive coverage. |
| Cake target descriptions only | Run both definitions' `--showdescription` commands, check that every target has a meaningful description, and confirm no target actions run. |
| HCL | Run `packer fmt -check src` as well as the affected behavior checks when executable behavior changes. |
| Ruby | Run `ruby -c <changed-file>` and the applicable behavior checks. Follow `.rubocop.yml`; generated and vendored `lib/` content is excluded. |
| Pipeline YAML | Parse the changed YAML and validate affected orchestration through its Cake operations and corresponding pipeline. |
| Documentation only | Read the exact changed text and its references, check links and relevant artifact syntax, and run `git diff --check`. Public Jekyll changes additionally use the site preview below. |

The public site preview runs through its existing container definition:

```shell
docker compose --file docs/site/compose.yml up --build
```

Generated boxes and images belong in ignored `artifacts/`. `packer_cache`, `.vagrant`, and `artifacts` MUST NOT be committed.

## Escalation

When a required tool or service fails, first distinguish a missing dependency from sandbox, permission, network, or host-integration restrictions. A blocked command MUST be retried through the platform's scoped escalation or approval mechanism. A container command that cannot reach the local Docker daemon MUST be retried outside the sandbox before any alternative tooling is considered.

Packages MUST NOT be installed, existing host tools replaced, or system configuration changed as a workaround without explicit user authorization. When a required dependency is unavailable locally and Docker is available, Docker MUST be used as the fallback; pulling container images and dependencies through Docker is allowed.

Changing a home-lab provider requires the maintainer to stop the current Azure agent service and start the required provider-specific service. An agent MUST request that intervention and wait for confirmation before queueing. Agent services and host tools MUST NOT be changed without explicit authorization.

Git operations SHOULD preserve history through additive commits, merges, and reverts. Amending existing commits, rebasing published commits, and force-pushing MUST NOT happen without the user's explicit request for that exact rewrite. If a rewrite appears necessary, request confirmation identifying the branch, commits, and remote; a general request to clean up, fix, commit, or push does not authorize it.

## Build and pipeline boundary

The [architecture invariants](architecture.md#invariants) establish Cake as the boundary for shared local and CI build logic. Pipeline YAML MUST be limited to stage and job orchestration, parameters and conditions, Azure-native artifact or publication tasks, minimal Cake bootstrap, and Cake invocations.

Repository-owned Ruby, PowerShell, shell one-liners, checksum logic, archive logic, path manipulation, and duplicated command sequences MUST NOT be embedded in pipeline YAML. Where bootstrap before Cake or an Azure task interface makes an inline script unavoidable, it MUST be minimal and have a comment explaining why it cannot live behind the Cake boundary.

## Coding conventions

HCL MUST use `packer fmt`. Packer's external-input boundary is defined by the [architecture invariants](architecture.md#invariants).

Ruby, YAML, and Cake MUST use two-space indentation. PowerShell and shell changes SHOULD follow the surrounding conventions. Shell files MUST retain LF and PowerShell files CRLF, as specified by `.gitattributes`. Markdown paragraphs and list items MUST each stay on one source line rather than being hard-wrapped.

Sample and image-variant directories MUST use lowercase, hyphenated names such as `ubuntu-server` and `25h2-enterprise`. Provider-specific files MUST follow the existing naming pattern, such as `source.virtualbox.pkr.hcl`.

## Build logs and delegation

Transient logs, captures, reports, payloads, and scratch files MUST be created under the system temporary directory in one directory per task. Complete Packer, Cake, Vagrant, Docker, and virtualization output MUST go to a unique log file in that task directory rather than the conversation.

Independent builds, tests, polling, broad exploration, and log analysis MUST be delegated to bounded workers when available. Requirements, decisions, integration, and final verification stay in the primary task. Workers SHOULD be read-only or build-only, with at most one writer per file set and no recursive delegation. Each build worker gets one configuration tuple or validation pass and returns its outcome, exact command, duration, exit status, first failing stage, relevant file references, a bounded error excerpt, and the complete log path.

Immediately before delegating, the primary agent MUST state the selected model and reasoning effort and why they fit the assignment. Quick formatting and syntax checks stay in the primary task; complete builds, repeated polling, and broad failure-log analysis SHOULD stay with workers. Completed workers SHOULD be closed and unrelated phases given to fresh workers.

## Azure home-lab orchestration

Each physical host runs one provider-specific agent service and one build at a time. Agent names on the same physical host do not add concurrency. Different physical hosts can each run one compatible build concurrently.

Builds MUST be queued against an exact branch and commit. Before queueing, check both `inProgress` and `notStarted` builds for the physical host. Ordered sequences MUST run serially, with the next queued only after the previous build succeeded with a clean timeline. Automation MUST stop on failure or a user request. Stopping a polling controller does not cancel a running build.

Pipelines without runtime parameters use `az pipelines build queue`. Parameterized pipelines MUST use the Build API, because that queue command cannot supply YAML template parameters:

```shell
az devops invoke --organization https://dev.azure.com/gusztavvargadr --area build --resource builds --route-parameters project=packer --api-version 7.1 --http-method POST --in-file <request.json>
```

The request MUST contain `definition.id`, `sourceBranch`, `sourceVersion`, and any `templateParameters`:

```json
{
  "definition": { "id": 123 },
  "sourceBranch": "refs/heads/feature/example",
  "sourceVersion": "<exact-commit-sha>",
  "templateParameters": { "example": "value" }
}
```

## Commits and pull requests

Requests and PRDs are tracked in this repository's GitHub Issues. Issue and pull-request operations use `gh`; the user-level delivery guides define the workflow. Domain terminology comes from the [product terms](product.md#terms), and implementation deviations belong in [architecture](architecture.md).

Delivery commits MUST follow the user-level delivery Git guide, including the target issue number. Other repository commits SHOULD use a short, imperative summary; merged summaries include the PR number. A delivery commit subject has this form:

```text
Describe repository build operations (#602)
```

Pull requests MUST describe affected samples, images, providers, and stages, link relevant issues, and report relevant commands or pipeline jobs run. Screenshots SHOULD be included only for documentation or visible guest-image changes.

## Secrets

Cloud credentials, Vagrant Cloud tokens, HCP secrets, product keys, and generated variable files containing secrets MUST NOT be committed. Publishing credentials belong in CI variable groups or local environment variables.
