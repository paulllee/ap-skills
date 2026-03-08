---
name: ap-update-docs
description: "Update README, AGENTS.md, and other project docs to reflect recent code changes."
argument-hint: "[description of what changed]"
disable-model-invocation: true
allowed-tools: Bash Read Write Edit Glob Grep Agent
---

# AP-Update-Docs

Update project docs to reflect recent code changes. Prefer tool calls over shell. Detect shell before Bash calls. Plain text output only.

## Steps

1. **Gather context:** Use `$ARGUMENTS` if provided, else run `git diff --stat HEAD~1` and `git log --oneline -5`.

2. **Scan for docs:** Glob `README.md`, `AGENTS.md`, `docs/**/*.md`, `CHANGELOG.md`, `API.md`.

3. **Analyze and update each doc** (skip if already accurate):
   - **README.md** — Update stale feature lists, usage, install instructions. Keep structure/tone. Add sections only for entirely new features.
   - **AGENTS.md** — Update Project Overview, Tech Stack, Build Tools if affected. Do NOT touch Lessons Learned or Architecture Decisions.
   - **CHANGELOG.md** — Prepend entry if project follows changelog convention.
   - **Other docs** — Fix stale content, don't rewrite correct content.

4. **Print summary:** One line per file updated. If nothing needed, say so.
