---
name: ap-init
description: Initialize a project with AGENTS.md, CLAUDE.md pointer, and docs/plans/ for the AP-n planning workflow.
argument-hint: "[project-name]"
disable-model-invocation: true
allowed-tools: Bash Read Write Edit Glob
---

# AP-Init

Set up the current project for AP-n planning. Prefer tool calls over shell commands. Detect shell before Bash calls — on PowerShell use the `.ps1` variants of scripts below. No commits. Plain text output only.

## Script helpers

Shared scripts live in `${CLAUDE_SKILL_DIR}/../ap-lib/bin/`. Use these instead of manual scanning.

- **detect-build-tools.sh / .ps1** — Scans project root for build/task files (Makefile, Justfile, package.json, etc.), extracts targets. Output: `file | tool_name | targets` per line.
- **detect-languages.sh / .ps1** — Detects languages from manifests and file extensions. Output: `language | confidence | evidence` per line.
- **list-docs.sh / .ps1** — Lists documentation files with line counts. Output: `path | size_lines` per line.

## Steps

1. **Project name:** Use `$ARGUMENTS` if provided, else derive from directory name.

2. **Check existing files:** Glob for `AGENTS.md`, `CLAUDE.md`. If any exist, ask per file: replace, integrate, or skip.

3. **Scan for build tools:** Run `bash "${CLAUDE_SKILL_DIR}/../ap-lib/bin/detect-build-tools.sh"` to detect build tools and their targets.

4. **Create AGENTS.md** (if missing or replace): Read `${CLAUDE_SKILL_DIR}/templates/AGENTS.md.template`, replace `{{PROJECT_NAME}}`, fill Build Tools from step 3. Write to root. If integrate, merge missing AP-n sections without overwriting.

5. **Auto-populate AGENTS.md** (no prompting):
   - **5a. Project info:** Explore repo. Populate **Project Overview** (1-3 sentences from README/manifests) and **Tech Stack** (languages, frameworks, key deps).
   - **5b. General standards:** Read `${CLAUDE_SKILL_DIR}/templates/STANDARDS-GENERAL.md` → inject into `### General`.
   - **5c. Language standards:** Run `bash "${CLAUDE_SKILL_DIR}/../ap-lib/bin/detect-languages.sh"` to detect languages. Read matching templates (`STANDARDS-PYTHON.md`, `STANDARDS-CSHARP.md`). Inject into `CLAUDE.local.md` (create/append, no duplicates). Replace `### Language-Specific` comment with: `See CLAUDE.local.md for language-specific standards.`
   - **5d.** Leave Architecture Decisions and Lessons Learned untouched.

6. **Create CLAUDE.md** (if missing or replace): Read `${CLAUDE_SKILL_DIR}/templates/CLAUDE.md.template`, write to root.

7. **Update .gitignore:** Ensure `docs/plans/` and `CLAUDE.local.md` entries exist. Create or append without duplicating.

8. **Create `docs/plans/`** directory.

9. **Suggest optional sub-skills:** Language standards (Python, C#) were already injected in 5c. Only offer tooling-specific extras:
   - Python project detected → offer `/ap-init-uv`
   - C#/.NET project detected → offer `/ap-init-dotnet`
   - Ask user which to run or skip.

10. **Print summary:** Files created/skipped/integrated, build tools found, language standards injected, suggest `/ap-plan <description>`.

## Examples

- `/ap-init`
- `/ap-init my-api`
