---
name: ap-init
description: Initialize a project with AGENTS.md, CLAUDE.md pointer, and docs/plans/ for the AP-n planning workflow.
argument-hint: "[project-name]"
disable-model-invocation: true
allowed-tools: Bash Read Write Edit Glob
---

# AP-Init

Set up the current project for AP-n planning. Use tool calls over shell commands for cross-platform safety. Detect the shell before any Bash calls and adapt commands accordingly.

## Steps

1. **Project name:** Use `$ARGUMENTS` if provided, otherwise derive from current directory name.

2. **Check existing files:** Glob for `AGENTS.md`, `CLAUDE.md`. If any exist, ask the user per file: replace, integrate (merge AP-n sections into existing content), or skip.

3. **Scan for build tools:** Glob the project root for build/task files. Read any that are found to extract available commands/targets. Look for:
   - `Makefile` / `GNUmakefile` — extract target names
   - `Justfile` — extract recipe names
   - `Taskfile.yml` / `Taskfile.yaml` — extract task names
   - `package.json` — extract `scripts` keys
   - `Dockerfile` / `docker-compose.yml` / `compose.yml` — note existence
   - `Rakefile`, `Cakefile`, `BUILD`, `build.gradle`, `pom.xml` — note existence

4. **Create AGENTS.md** (if missing or user chose replace): Read `${CLAUDE_SKILL_DIR}/templates/AGENTS.md.template`, replace `{{PROJECT_NAME}}`. If build tools were found in step 3, fill in the `## Build Tools` section with the tool name and its available commands/targets. Write to project root. If user chose integrate, read the existing AGENTS.md and merge in any missing AP-n sections (Build Tools, Lessons Learned, etc.) without overwriting existing content.

5. **Auto-populate AGENTS.md:** Always scan the project and populate — no prompting.

   **5a. Project info:** Use `ls`, Bash, and file reads to explore the repo. Populate these sections:
   - **Project Overview** — Read `README.md` (if it exists) and any project manifest (`package.json` description, `pyproject.toml` project.description, `Cargo.toml`, `*.csproj`, etc.). Write a 1–3 sentence summary.
   - **Tech Stack** — List languages, frameworks, and key dependencies discovered from manifests and file extensions.

   **5b. General standards:** Read `${CLAUDE_SKILL_DIR}/templates/STANDARDS-GENERAL.md` and inject its content into the `### General` section of AGENTS.md, replacing the `<!-- Auto-populated by /ap-init -->` comment.

   **5c. Language-specific standards:** Detect languages from file extensions and manifests. Read matching standards template files:
   - Python detected (`*.py`, `pyproject.toml`, `requirements.txt`) → read `${CLAUDE_SKILL_DIR}/templates/STANDARDS-PYTHON.md`
   - C#/.NET detected (`*.cs`, `*.csproj`, `*.sln`) → read `${CLAUDE_SKILL_DIR}/templates/STANDARDS-CSHARP.md`

   **Routing:** Always inject language standards into `CLAUDE.local.md` (create if missing, append if exists — do not duplicate sections already present). Replace the `### Language-Specific` comment in AGENTS.md with: `See CLAUDE.local.md for language-specific standards.`

   **5d.** Leave **Architecture Decisions** and **Lessons Learned** sections untouched (those are filled over time).

6. **Create CLAUDE.md** (if missing or user chose replace): Read `${CLAUDE_SKILL_DIR}/templates/CLAUDE.md.template`, write to project root.

7. **Update .gitignore:** Ensure `docs/plans/` and `CLAUDE.local.md` entries exist. Create the file if missing, or append missing entries without duplicating.

8. **Create `docs/plans/` directory** via shell.

9. **Detect project type and suggest language sub-skills for additional customization:** Look for signals in the project root and suggest matching skills. Since basic language standards are already auto-injected, frame these as optional for further customization:
   - `pyproject.toml`, `setup.py`, `requirements.txt`, `.py` files → suggest `/ap-init-python` (additional coding standards) and `/ap-init-uv` (build tooling)
   - `*.csproj`, `*.sln`, `*.cs` files → suggest `/ap-init-cs` (additional coding standards) and `/ap-init-dotnet` (build tooling)
   - Note: basic language standards were already added in step 5d. These sub-skills are for additional customization only.
   - If detected, ask the user which ones to run. They can pick any combination or skip.
   - If nothing detected or user declines, skip.

10. **Print summary:** Plain text. List created/skipped/integrated files, build tools found, which language standards were auto-injected into CLAUDE.local.md, then suggest `/ap-plan <description>`.

Do NOT create a git commit.
