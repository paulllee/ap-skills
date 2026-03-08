---
name: ap-init-cs
description: Add C# coding standards to AGENTS.md — naming, braces, nullability conventions.
disable-model-invocation: true
allowed-tools: Read Edit Glob
---

# AP-Init-CS

Inject C# coding standards into the project's `AGENTS.md`. Plain text output only.

## Steps

1. Read `AGENTS.md`. If missing, tell user to run `/ap-init` first.

2. **Idempotency:** If `**C# Coding Standards**` exists in `CLAUDE.local.md` or `AGENTS.md`, merge/update without duplicating. Preserve user customizations.

3. **Target file:** Default `CLAUDE.local.md` (create if missing). Use AGENTS.md only if `$ARGUMENTS` contains `--agents-md`.

4. Inject (replace placeholder comment or append):

```
- **C# Coding Standards**
  - Mandatory braces on all control flow (if, else, for, foreach, while, using)
  - PascalCase for public members, _camelCase for private fields
  - Enable nullable reference types (`<Nullable>enable</Nullable>`)
  - XML doc comments on public APIs
  - Prefer pattern matching over type casting
  - Prompt the user before modifying `.sln` files
```

5. Print what was added/updated and where.
