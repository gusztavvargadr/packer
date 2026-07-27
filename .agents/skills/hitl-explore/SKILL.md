---
name: hitl-explore
description: Guide a stepwise, evidence-capturing maintainer discussion when exploring a feature, code section, CLI or product flow, implementation behavior, workflow, process, or skill design without implementation.
---

## Summary

Guide a maintainer through an evidence-first review, one concept or observable step at a time. Pause for reaction before settling each step.

## Workflow

### Ground the session

Read targeted local docs, code, diffs, status, reports, or supplied artifacts before asking broad questions. State the goal, evidence path, boundary, and first review step.

### Start the rolling report

Create a rolling report once scope and evidence are clear, using the complete [exploration report template](references/exploration-report-template.md).

### Review each step

Review one concept, command, artifact, behavior, or workflow step at a time using the shape below. Pause for maintainer reaction before moving on.

### Maintain the evidence

Update the report after meaningful evidence, decisions, or direction changes. Periodically summarize what is known, unclear, and the next single step.

The initial evidence pass may use several read-only inspections. After orientation, keep the walkthrough to one action or concept at a time.

## Step review

- **Evidence**: what was read, observed, run, or supplied.
- **Interpretation**: what it seems to mean.
- **Challenge**: risks, friction, complexity, assumptions, failure modes, alternative readings, or simplifications.
- **Recommendation**: the best current option or classification.
- **Pause**: ask for reaction before continuing.

Use works well, works but awkward, incorrect behavior, unclear or needs more evidence, or follow-up design idea when useful.

## Rolling report

Write one complete generated report to the repository's `.tmp/` directory when it is gitignored. Otherwise resolve the OS temporary directory from `$TMPDIR`, falling back to `/tmp` on macOS and Linux or `%TEMP%` on Windows. Give each report a topic-based filename.

Keep the report useful if the session stops midway. Update it as evidence and decisions accumulate, and preserve concrete commands, paths, important excerpts, tool evidence, observations, and prompts. Record maintainer decisions as decisions rather than inferred findings. Persist it in the repository only when the maintainer explicitly selects a durable owner for this exploration.

## Synthesis

When the review is sufficient, consolidate evidence, decisions, strongest findings, direction, and follow-up themes. Draft a separate implementation plan only when asked. Do not turn findings into items, tasks, item artifacts, or plans or change the provider unless the maintainer explicitly switches workflows.

Keep prompts direct and stateful: evidence, interpretation, challenge, recommendation, and pause. Explain why a result changes the exploration path before proposing the next step.

## Boundaries and failures

The exploration changes only its rolling report. Do not implement fixes, complete items or tasks, create item artifacts or tasks, commit, publish pull-request reviews, or change the provider unless the maintainer explicitly changes workflows.

- Diagnose a failed command before continuing.
- Ask for the smallest useful evidence when state is ambiguous.
- Refuse unsafe or unclear paths; reserve “reject” for transitioning an item or task to a not-planned terminal outcome.
- Record serious findings immediately and choose a safe next step.
- If asked to fix something, pause and make the workflow switch explicit.
