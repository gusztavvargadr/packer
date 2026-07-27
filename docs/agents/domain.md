# Domain docs

## Before exploring

Read these when they exist:

- Root `CONTEXT.md`
- Relevant ADRs under `docs/adr/`

Proceed silently when either is absent. The domain-modeling workflow creates them
when terminology or architectural decisions are resolved.

## Layout

This is a single-context repository:

```text
/
├── CONTEXT.md
├── docs/adr/
└── src/
```

## Style

Use sentence case for headings, glossary term labels, and ADR titles. Capitalize
only the first word and proper names.

## Known implementation deviations

An image family is a domain boundary, not a `samples/` directory:

- Docker currently spans `samples/docker-linux/` and `samples/docker-windows/`.
- Development currently spans `samples/development-ubuntu/` and
  `samples/development-windows/`.
- Kitchen currently spans `samples/kitchen-ubuntu/` and
  `samples/kitchen-windows/`.

Treat each pair as one image family until its samples are consolidated. Use
`sample` only for the current repository partition and build parameter, not as a
synonym for image family.

## Vocabulary

Use domain terms as defined in `CONTEXT.md`. Avoid synonyms the glossary explicitly
rejects. If a needed concept is missing, reconsider the terminology or record the
gap for domain modeling.

## ADR conflicts

Explicitly flag output that contradicts an existing ADR rather than silently
overriding the decision.
