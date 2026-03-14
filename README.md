# ap-skills

A distributable skill system for the AP-n agentic planning pattern, following the [Agent Skills open standard](https://agentskills.io). Skills are installed to both `~/.claude/skills/` and `~/.cursor/skills/` so they're auto-discovered by Claude Code and Cursor — one install, both tools.

## Skills

| Skill | Description |
|-------|-------------|
| `/ap-init [project-name]` | Initialize a project with AGENTS.md, CLAUDE.md pointer, and docs/plans/ |
| `/ap-init-python` | Add Python coding standards (type hints, docstrings, naming) to AGENTS.md |
| `/ap-init-uv` | Add Python build tooling (uv, ruff, pytest) to AGENTS.md |
| `/ap-init-cs` | Add C# coding standards (braces, naming, nullability) to AGENTS.md |
| `/ap-init-dotnet` | Add .NET build tooling (dotnet CLI, formatting, tests) to AGENTS.md |
| `/ap-plan <description>` | Full AP-n workflow: research, propose, peer-review, decide, implement, update docs, insights |
| `/ap-update-docs` | Update README, AGENTS.md, and other project docs to reflect recent code changes |
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

1. Research — parallel subagents explore the codebase
2. Propose — Agent A generates 2-4 approaches with pros/cons
3. Peer Review — Agent B critiques proposals independently
4. User Decision — hard gate, no implementation without approval
5. Implementation — applies chosen approach following AGENTS.md standards
6. Save Plan — writes `docs/plans/AP-{N}.md`
7. Lessons Learned — appends discoveries to AGENTS.md
8. Update Docs — syncs README, AGENTS.md, and other docs with what changed
9. Insights — prints summary of what changed and why
