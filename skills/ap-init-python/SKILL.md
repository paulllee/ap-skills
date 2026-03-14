---
name: ap-init-python
description: "Add Python coding standards to CLAUDE.local.md — type hints, docstrings, naming conventions. Auto-invoked by /ap-init for Python projects, or run standalone."
disable-model-invocation: true
allowed-tools: Read Edit Glob
---

# AP-Init-Python

Inject Python coding standards into the project's `CLAUDE.local.md` (or `AGENTS.md` with `--agents-md` flag). Plain text output only.

## Steps

1. Read `AGENTS.md`. If missing, tell user to run `/ap-init` first.

2. **Idempotency:** If `**Python Coding Standards**` exists in `CLAUDE.local.md` or `AGENTS.md`, merge/update without duplicating. Preserve user customizations.

3. **Target file:** Default `CLAUDE.local.md` (create if missing). Use AGENTS.md only if `$ARGUMENTS` contains `--agents-md`.

4. Inject (replace placeholder comment or append):

```
- **Python Coding Standards**
  - Type hints on all function signatures (params and return types)
  - Docstrings on public functions/classes (Google style)
  - snake_case for functions/variables, PascalCase for classes
  - Prefer f-strings over .format() or %
  - Use pathlib over os.path
  - Imports: stdlib, blank line, third-party, blank line, local
```

5. Print what was added/updated and where.

## Examples

- `/ap-init-python`
- `/ap-init-python --agents-md`
