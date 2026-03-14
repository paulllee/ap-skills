---
name: ap-update-docs
description: "Update README, AGENTS.md, and other project docs to reflect recent code changes."
argument-hint: "[description of what changed]"
disable-model-invocation: true
allowed-tools: Bash Read Write Edit Glob Grep Agent
---

# AP-Update-Docs

Update project docs to reflect recent code changes. Prefer tool calls over shell. Detect shell before Bash calls — on PowerShell use the `.ps1` variants of scripts below. Plain text output only.

## Script helpers

Shared scripts live in `${CLAUDE_SKILL_DIR}/../ap-lib/bin/`. Use these instead of manual git/glob logic.

- **summarize-changes.sh / .ps1** — Parses git diff and log. Output: DIFF, CHANGED FILES, CATEGORIES (docs/code/config/tests counts), and LOG sections. Handles edge cases (no history, single commit).
- **list-docs.sh / .ps1** — Lists documentation files with line counts. Output: `path | size_lines` per line.

## Steps

1. **Gather context:** Use `$ARGUMENTS` if provided, else run `bash "${CLAUDE_SKILL_DIR}/../ap-lib/bin/summarize-changes.sh"` to get structured change summary.

2. **Scan for docs:** Run `bash "${CLAUDE_SKILL_DIR}/../ap-lib/bin/list-docs.sh"` to list all documentation files.

3. **Analyze and update each doc** (skip if already accurate):
   - **README.md** — Update stale feature lists, usage, install instructions. Keep structure/tone. Add sections only for entirely new features.
   - **AGENTS.md** — Update Project Overview, Tech Stack, Build Tools if affected. Do NOT touch Lessons Learned or Architecture Decisions.
   - **CHANGELOG.md** — Prepend entry if project follows changelog convention.
   - **Other docs** — Fix stale content, don't rewrite correct content.

4. **Print summary:** One line per file updated. If nothing needed, say so.

## Troubleshooting

- **No git history:** Fall back to scanning all docs for completeness rather than diffing changes.
- **No docs found:** Report that no documentation files were found; suggest running `/ap-init` first.

## Examples

- `/ap-update-docs`
- `/ap-update-docs added WebSocket support`
