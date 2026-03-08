---
name: ap-update-docs
description: "Update README, AGENTS.md, and other project docs to reflect recent code changes."
argument-hint: "[description of what changed]"
disable-model-invocation: true
allowed-tools: Bash Read Write Edit Glob Grep Agent
---

# AP-Update-Docs

Update project documentation to reflect recent code changes. Use tool calls over shell commands for cross-platform safety. Detect the shell before any Bash calls and adapt commands accordingly. Print plain text — no fancy formatting or decorative output.

## When to run

- After implementation phases in `/ap-plan`
- Standalone when the user wants docs synced with code

## Steps

1. **Gather context:** If `$ARGUMENTS` is provided, use it as a summary of what changed. Otherwise, run `git diff --stat HEAD~1` and `git log --oneline -5` to identify recent changes.

2. **Scan for docs to update:** Glob for these files in the project root and common locations:
   - `README.md`
   - `AGENTS.md`
   - `docs/**/*.md`
   - `CHANGELOG.md`
   - `API.md`

3. **Analyze each doc:** For each doc found, read it and determine if the recent changes affect its content. Skip docs that are already accurate.

4. **Update README.md** (if exists and affected):
   - Keep the existing structure and tone
   - Update feature lists, usage examples, install instructions, or API docs that are now stale
   - Add new sections only if the changes introduced something entirely new (e.g., new CLI command, new skill, new dependency)
   - Do not rewrite sections that are still accurate

5. **Update AGENTS.md** (if exists and affected):
   - Update **Project Overview** or **Tech Stack** if new dependencies, languages, or major components were added
   - Update **Build Tools** if new commands/targets were introduced
   - Do NOT touch **Lessons Learned** or **Architecture Decisions** — those are managed by `/ap-plan`

6. **Update other docs** (if found and affected):
   - Apply the same principle: fix what's stale, don't rewrite what's correct
   - For `CHANGELOG.md`, prepend a new entry if one exists and the project follows a changelog convention

7. **Print summary:** List each file updated with a one-line description of what changed. If no docs needed updating, say so.
