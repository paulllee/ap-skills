---
name: ap-init-python
description: Add Python coding standards to AGENTS.md — type hints, docstrings, naming conventions.
disable-model-invocation: true
allowed-tools: Read Edit Glob
---

# AP-Init-Python

Inject Python coding standards into the project's `AGENTS.md`.

## Steps

1. Read `AGENTS.md`. If it doesn't exist, tell the user to run `/ap-init` first.

2. **Idempotency check:** Check if `**Python Coding Standards**` already exists in `CLAUDE.local.md` or `AGENTS.md`. If Python standards are found in either file, merge/update the content rather than duplicating — preserve any user customizations and add only missing items.

3. **Determine target file:** Default to `CLAUDE.local.md` (create if missing). Only inject into AGENTS.md if `$ARGUMENTS` contains `--agents-md`.

4. Inject the following into the target file (replace HTML comment placeholder if present, or append):

```
- **Python Coding Standards**
  - Type hints on all function signatures (params and return types)
  - Docstrings on public functions/classes (Google style)
  - snake_case for functions/variables, PascalCase for classes
  - Prefer f-strings over .format() or %
  - Use pathlib over os.path
  - Imports: stdlib, blank line, third-party, blank line, local
```

5. Print what was added or updated, and where (AGENTS.md or CLAUDE.local.md). Plain text.
