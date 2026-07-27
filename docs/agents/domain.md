# Domain Docs

## Before exploring

Read these when they exist:

- Root `CONTEXT.md`
- Relevant ADRs under `docs/adr/`

Proceed silently when either is absent. The domain-modeling workflow creates them when terminology or architectural decisions are resolved.

## Layout

This is a single-context repository:

```text
/
├── CONTEXT.md
├── docs/adr/
└── src/
```

## Vocabulary

Use domain terms as defined in `CONTEXT.md`. Avoid synonyms the glossary explicitly rejects. If a needed concept is missing, reconsider the terminology or record the gap for domain modeling.

## ADR conflicts

Explicitly flag output that contradicts an existing ADR rather than silently overriding the decision.
