---
name: ap-init-uv
description: "Add uv/ruff/pytest build tooling standards to AGENTS.md. Use after /ap-init on Python projects using uv."
disable-model-invocation: true
allowed-tools: Read Edit Glob
---

# AP-Init-UV

Inject Python build tooling standards (uv, ruff, pytest) into the project's `AGENTS.md`.

## Steps

1. Read `AGENTS.md`. If it doesn't exist, tell the user to run `/ap-init` first.

2. Find the `## Build Tools` section. If it doesn't exist, create it after `## Tech Stack`.

3. Append under `## Build Tools` (or replace the HTML comment placeholder):

```
### Python (uv)
- Package manager: `uv` (not pip/poetry). Use `uv add` for deps, `uv run` to execute.
- Linting: `uv tool run ruff check --fix .`
- Formatting: `uv tool run ruff format .`
- Tests: `uv run pytest`
- Type checking: `uv run mypy .` (if mypy is a dev dependency)
- Run both lint and format after implementation: `uv tool run ruff check --fix . && uv tool run ruff format .`
```

4. Print what was added. Plain text.

## Examples

- `/ap-init-uv`
