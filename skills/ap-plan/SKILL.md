---
name: ap-plan
description: "Run the AP-n agentic planning workflow: research, propose solutions, peer-review, user decision, implement, insights."
argument-hint: "<feature or problem description>"
disable-model-invocation: true
allowed-tools: Bash Read Write Edit Glob Grep Agent EnterPlanMode ExitPlanMode
---

# AP-Plan

Run the AP-n planning cycle for: **$ARGUMENTS**

Follow all 9 phases in order. Do not implement before user approval. Track progress with the task list, updating after each phase. No commits. Detect shell before Bash calls. Plain text output only.

## Pre-flight

1. Glob `docs/plans/AP-*.md` → find next plan number N (default 1).
2. Create a task list with all 9 phases.
3. Call `EnterPlanMode` if available — Phases 1-3 run in plan mode.

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

## Phase 5: Implementation

1. Re-read key files (may have been evicted) and `AGENTS.md` for project standards.
2. Implement chosen approach per `AGENTS.md` conventions.
3. Run lint/format/test commands if specified in `AGENTS.md`.

## Phase 6: Save Plan

Read `${CLAUDE_SKILL_DIR}/templates/AP-n.md.template`, fill from phase outputs, write to `docs/plans/AP-{N}.md`.

## Phase 7: Lessons Learned

Append new one-line discoveries to `AGENTS.md` → `## Lessons Learned`. No duplicates.

## Phase 8: Update Docs

Scan README.md, AGENTS.md, and project docs. Update anything stale from implementation. Do NOT touch Lessons Learned or Architecture Decisions. Skip if nothing changed.

## Phase 9: Insights

Always print. Label "Insights:" then:
- File count and plan number
- One bullet per modified file with what changed
- Any lessons added
