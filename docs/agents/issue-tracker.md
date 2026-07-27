# Issue tracker: GitHub

Issues and PRDs for this repo live as GitHub issues. Use the `gh` CLI for all operations.

## Conventions

- **Create an issue**: `gh issue create --title "..." --body "..."`. Use a heredoc for multi-line bodies.
- **Read an issue**: `gh issue view <number> --comments`, filtering comments by `jq` and also fetching labels.
- **List issues**: `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'` with appropriate `--label` and `--state` filters.
- **Comment on an issue**: `gh issue comment <number> --body "..."`
- **Apply / remove labels**: `gh issue edit <number> --add-label "..."` / `--remove-label "..."`
- **Close**: `gh issue close <number> --comment "..."`

Infer the repo from `git remote -v` — `gh` does this automatically when run inside a clone.

## Pull requests as a triage surface

**PRs as a request surface: no.**

When enabled, PRs run through the same labels and states as issues using the equivalent `gh pr` commands. GitHub shares one number space across issues and PRs, so resolve an ambiguous `#42` with `gh pr view 42`, then fall back to `gh issue view 42`.

## Skill operations

- **Publish to the issue tracker**: create a GitHub issue.
- **Fetch the relevant ticket**: run `gh issue view <number> --comments`.
- **Map**: an issue labelled `wayfinder:map`, containing Notes, Decisions-so-far, and Fog.
- **Child ticket**: a GitHub sub-issue, or a task-list entry with `Part of #<map>`.
- **Blocking**: use GitHub’s native issue dependencies; fall back to a `Blocked by: #<n>` line.
- **Claim**: `gh issue edit <n> --add-assignee @me`.
- **Resolve**: comment with the answer, close the issue, and add its context pointer to the map.
