# ap-skills

## Project Overview

A distributable skill system for the AP-n agentic planning pattern, following the Agent Skills open standard. Skills are installed to both `~/.claude/skills/` and `~/.cursor/skills/` so they're auto-discovered by Claude Code and Cursor. Includes skills for project initialization, planning workflows, documentation updates, and language-specific standards.

## Tech Stack

- Shell (Bash/PowerShell install scripts)
- Markdown (skill definitions, templates, documentation)
- Claude Code / Cursor skills system (`~/.claude/skills/`, `~/.cursor/skills/`)

## Build Tools

No build tools detected. Install via `bash install.sh` (macOS/Linux) or `.\install.ps1` (Windows).

## Development Standards

### General
- Keep changes minimal and focused
- Prefer editing existing files over creating new ones
- No autocommit — the developer commits when ready
- Keep skill definitions slim — every line costs tokens at invocation

### Language-Specific
No language-specific standards applicable.

## Architecture Decisions

<!-- Record why things are built a certain way so an agent can revisit the reasoning. -->

## Lessons Learned

<!-- One-line discoveries appended by /ap-plan after each run. Do not duplicate entries. -->
