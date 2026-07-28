# Documentation

Repository-maintenance documentation lives directly in this directory. Agent guidance belongs in `agents/`, and architectural decision records belong in `adr/`.

The public Jekyll site is the self-contained `site/` subtree. Public image documentation and release posts belong there. To preview the site locally from the repository root, run:

```shell
docker compose --file docs/site/compose.yml up --build
```
