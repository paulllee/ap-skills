# ap-skills

A distributable skill system for the AP-n agentic planning pattern, following the [Agent Skills open standard](https://agentskills.io). Skills are installed to both `~/.claude/skills/` and `~/.cursor/skills/` so they're auto-discovered by Claude Code and Cursor — one install, both tools.

## Skills

| Skill | Description |
|-------|-------------|
| `/ap-init [project-name]` | Initialize a project with AGENTS.md, CLAUDE.md pointer, and docs/plans/ |
| `/ap-init-python` | Add Python coding standards (type hints, docstrings, naming) to CLAUDE.local.md |
| `/ap-init-uv` | Add Python build tooling (uv, ruff, pytest) to AGENTS.md |
| `/ap-init-cs` | Add C# coding standards (braces, naming, nullability) to CLAUDE.local.md |
| `/ap-init-dotnet` | Add .NET build tooling (dotnet CLI, formatting, tests) to AGENTS.md |
| `/ap-plan <description>` | AP-n workflow: research, propose, peer-review, user decision, test-first, implement with subagents, code review, performance testing |
| `/ap-update-docs [description]` | Update README, AGENTS.md, and other project docs to reflect recent code changes |
| `/ap-docs <query> [library]` | Documentation lookup via Context7 MCP with WebFetch/curl fallback |

## Install

macOS / Linux:
```bash
bash install.sh
```

Windows (PowerShell):
```powershell
.\install.ps1
```

Both scripts copy `skills/*/` into `~/.claude/skills/` and `~/.cursor/skills/`.

## Cross-IDE Strategy

- `AGENTS.md` — single source of truth for project context (Cursor reads natively)
- `CLAUDE.md` — thin pointer with `@AGENTS.md` import (Claude Code auto-reads)
- `CLAUDE.local.md` — personal overrides, gitignored (Claude Code auto-reads)

## AP-n Workflow Phases

> **Model tiers:** sonnet agents handle research, tests, and implementation; opus agents handle proposals, peer review, and code review.

1. **Research** — parallel sonnet subagents explore the codebase with distinct focus areas
2. **Propose** — opus Agent A generates 2-4 approaches with pros/cons/complexity
3. **Peer Review** — opus Agent B critiques proposals independently (does not pick a winner)
4. **User Decision** — hard gate, no implementation without explicit approval
4.5. **Write Plan** — fills `docs/plans/AP-{N}.md` with acceptance criteria, implementation steps, and performance criteria
5. **Test First** — writes unit and integration tests before any implementation code
6. **Implement** — parallel sonnet subagents with worktree isolation for independent steps
6.5. **Integration** — janitor agent runs full test suite, fixes cross-step integration issues
7. **Code Review** — opus agent reviews all changes; blocking findings trigger fix→review loops (up to 3 iterations)
8. **Performance Testing** — benchmarks against plan criteria (skipped if N/A)
9. **Wrap-up** — updates plan status, appends lessons to AGENTS.md, syncs docs, prints insights

## Helper Scripts

Skills share reusable shell scripts (bash + PowerShell variants) via `ap-lib/bin/`:

| Script | Purpose |
|--------|---------|
| `detect-build-tools` | Finds Makefile, package.json, gradle, docker, etc. |
| `detect-languages` | Detects Python, TypeScript, Go, Rust, C#, and 15+ others |
| `list-docs` | Lists documentation files with line counts |
| `append-lessons` | Appends a lesson to AGENTS.md with deduplication |
| `summarize-changes` | Parses git diff/log for change summaries |

`ap-plan` also has its own scripts in `ap-plan/bin/`:

| Script | Purpose |
|--------|---------|
| `ap-next-plan` | Creates `docs/plans/` and the next AP-N.md file |
| `ap-status` | Lists all AP-*.md plans with title, date, and status |
