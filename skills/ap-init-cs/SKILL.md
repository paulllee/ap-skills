---
name: ap-init-cs
description: Add C# coding standards to AGENTS.md — naming, braces, nullability conventions.
disable-model-invocation: true
allowed-tools: Read Edit Glob
---

# AP-Init-CS

Inject C# coding standards into the project's `AGENTS.md`.

## Steps

1. Read `AGENTS.md`. If it doesn't exist, tell the user to run `/ap-init` first.

2. **Idempotency check:** Check if `**C# Coding Standards**` already exists in `CLAUDE.local.md` or `AGENTS.md`. If C# standards are found in either file, merge/update the content rather than duplicating — preserve any user customizations and add only missing items.

3. **Determine target file:** Default to `CLAUDE.local.md` (create if missing). Only inject into AGENTS.md if `$ARGUMENTS` contains `--agents-md`.

4. Inject the following into the target file (replace HTML comment placeholder if present, or append):

```
- **C# Coding Standards**
  - Mandatory braces on all control flow (if, else, for, foreach, while, using)
  - PascalCase for public members, _camelCase for private fields
  - Enable nullable reference types (`<Nullable>enable</Nullable>`)
  - XML doc comments on public APIs
  - Prefer pattern matching over type casting
  - Prompt the user before modifying `.sln` files
```

5. Print what was added or updated, and where (AGENTS.md or CLAUDE.local.md). Plain text.
