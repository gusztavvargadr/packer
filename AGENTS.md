# Agents

Read [README.md](README.md) and [CONTRIBUTING.md](CONTRIBUTING.md) before changing anything.

## Ask before

- Running the `publish` target, or anything else that writes to R2 or the registry, because a released key can't be overwritten and a release version can't be published again.
- Removing a box version under the [retention policy](CONTRIBUTING.md#retention).
- Installing packages, or changing host tools or configuration, because they affect more than this repository.

## Builds

Test with builds on the hosts available to you, and leave queueing pipelines to the maintainer.

## Conventions

- Specs and plans go on the issue or the pull request, not in `docs/superpowers`.
- Review findings go on the pull request, as review comments on the lines they concern. Each thread gets a reply saying what was done: fixed (with the commit), moved to an issue (with the link), or left as is (with why). Then the thread is resolved.
- Findings outside the pull request's scope become issues.
- Run the checks [CONTRIBUTING.md](CONTRIBUTING.md#checks) lists for the change, and where one couldn't run, say so in the pull request rather than reporting a pass.
