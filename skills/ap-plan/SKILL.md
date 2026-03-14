---
name: ap-plan
description: "Run the AP-n agentic planning workflow: research, propose solutions, peer-review, user decision, implement."
argument-hint: "(feature or problem description)"
disable-model-invocation: true
allowed-tools: Bash Read Write Edit Glob Grep Agent EnterPlanMode ExitPlanMode
---

# AP-Plan

Run the AP-n planning cycle for: **$ARGUMENTS**

Follow all 5 phases in order. Do not implement before user approval. Track progress with the task list, updating after each phase. No commits. Detect shell before Bash calls — on PowerShell use the `.ps1` variants of scripts below.

## Script helpers

All scripts live in `${CLAUDE_SKILL_DIR}/bin/`. Use these instead of manual glob/parse logic.

- **ap-next-plan.sh / .ps1** — Creates `docs/plans/` if needed, finds the next AP-N number, creates the file, prints the absolute path to stdout.
- **ap-status.sh / .ps1** — Parses all existing AP-*.md plans and prints one line per plan: `path | title | date | status`.

## Pre-flight

1. Run `bash "${CLAUDE_SKILL_DIR}/bin/ap-next-plan.sh"` (or `.ps1` on PowerShell) → capture the output as `PLAN_FILE`.
2. Run `bash "${CLAUDE_SKILL_DIR}/bin/ap-status.sh"` to display existing plans for context.
3. Create a task list with all 5 phases.
4. Call `EnterPlanMode` if available — Phases 1-3 run in plan mode.

## Phase 1: Research

Launch 2-3 parallel Agent subagents with distinct focus areas. Each returns bullet findings and top 5 relevant files.

Synthesize a **Research Summary** from deduplicated top files: current state, patterns, constraints, affected files.

## Phase 2: Propose (Agent A)

Single Agent receives request, Research Summary, and key file contents. Returns **2-4 approaches**: name, description (2-3 sentences), pros, cons, complexity (Low/Medium/High). No implementation.

## Phase 3: Peer Review (Agent B)

Single Agent receives Agent A's proposals **verbatim** and Research Summary. Returns per-proposal: incorrect assumptions, missed risks, complexity corrections, optional refinements. Does NOT pick a winner.

## Phase 4: User Decision

Call `ExitPlanMode` if it was used.

Present Research Summary, proposals, and review. Ask the user which approach to proceed with.

**HARD BLOCK — no implementation until the user explicitly chooses.** If all rejected, return to Phase 2 with feedback.

## Phase 4.5: Write Plan

Before implementing, write the plan to `PLAN_FILE` (captured in Pre-flight). Read `${CLAUDE_SKILL_DIR}/templates/AP-n.md.template`, fill it from the phase outputs collected so far (set Status to **In Progress**), and write to `PLAN_FILE`. This ensures subagents can reference the plan during implementation.

## Phase 5: Implementation & Wrap-up

1. Re-read key files (may have been evicted) and `AGENTS.md` for project standards.
2. Implement chosen approach per `AGENTS.md` conventions.
3. Run lint/format/test commands if specified in `AGENTS.md`.
4. **Update plan:** Re-read `PLAN_FILE`, fill in Implementation Notes and Files Modified, set Status to **Complete**, and write back.
5. **Lessons learned:** Append new one-line discoveries to `AGENTS.md` → `## Lessons Learned`. No duplicates.
6. **Update docs:** Scan README.md, AGENTS.md, and project docs. Update anything stale from implementation. Do NOT touch Lessons Learned or Architecture Decisions. Skip if nothing changed.
7. **Insights** — always print. Label "Insights:" then: file count and plan number, one bullet per modified file with what changed, any lessons added.

## Troubleshooting

- **No `docs/plans/` directory:** The scripts create it automatically.
- **Agent subagent timeout:** Retry once with a narrower focus area, then proceed with available findings.

## Examples

- `/ap-plan add user authentication`
- `/ap-plan fix flaky integration tests`
