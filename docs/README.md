# Documentation

Repository-maintenance guidance lives directly in this directory. The [agent instructions](../AGENTS.md) declare the user-level skill setup, `guides-g`, and the repository's category documents. [Claude's instruction entry point](../CLAUDE.md) is a relative symlink to those same instructions.

| Document | Contents |
| --- | --- |
| [Product](product.md) | Purpose, approach, capabilities, direction, and domain terms |
| [Architecture](architecture.md) | Current system, implemented decisions and rationale, dependency boundaries, implementation deviations, and invariants |
| [Engineering](engineering.md) | Build entry point, validation, coding conventions, escalation, host orchestration, and Git safety |

Requests, including unresolved architecture decisions, are tracked in GitHub Issues through the workflow described by the user-level delivery guides.

The public Jekyll site is the self-contained [site subtree](site/). Consumer image documentation and release posts belong there. The site preview command and validation requirements are in [engineering checks](engineering.md#checks).
