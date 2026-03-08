---
name: ap-plan
description: "Run the AP-n agentic planning workflow: research, propose solutions, peer-review, user decision, implement, insights."
argument-hint: "<feature or problem description>"
disable-model-invocation: true
allowed-tools: Bash Read Write Edit Glob Grep Agent EnterPlanMode ExitPlanMode
---

# AP-Plan

Run the AP-n planning cycle for: **$ARGUMENTS**

Follow all 9 phases in order. Do not implement before user approval. Track progress with the task list, updating after each phase. Do NOT create git commits. Detect the shell before any Bash calls and adapt commands accordingly. Print plain text — no fancy formatting or decorative output.

## Pre-flight

1. Glob `docs/plans/AP-*.md` to find the next plan number N (default 1).
2. Create a task list with all 9 phases.
3. If `EnterPlanMode` is available, call it now — Phases 1-3 run in plan mode. If unavailable, continue normally.

## Phase 1: Research

Launch 2-3 parallel Agent subagents with distinct codebase focus areas. Each returns:
- Bullet-point findings (no prose)
- Top 5 relevant files

After completion: read the top files (deduplicated), synthesize a **Research Summary** covering current state, patterns, constraints, and affected files.

## Phase 2: Propose (Agent A)

Single Agent subagent receives the request, Research Summary, and key file contents. Returns **2-4 approaches**, each with: name, description (2-3 sentences), pros, cons, complexity (Low/Medium/High). No implementation.

## Phase 3: Peer Review (Agent B)

Single Agent subagent receives Agent A's proposals **verbatim** and the Research Summary. Returns per-proposal: incorrect assumptions, missed risks/edge cases, complexity corrections, optional refinements. Does NOT pick a winner.

## Phase 4: User Decision

If `EnterPlanMode` was used, call `ExitPlanMode` now.

Present: Research Summary, Agent A proposals, Agent B review. Ask the user which approach to proceed with.

**HARD BLOCK — no implementation until the user explicitly chooses.** If all rejected, return to Phase 2 with feedback.

## Phase 5: Implementation

1. Re-read key files (may have been evicted from context) and `AGENTS.md` for project standards.
2. Implement the chosen approach following conventions in `AGENTS.md`.
3. If `AGENTS.md` specifies linting/formatting/test commands under Development Standards or Build Tools, run them.

## Phase 6: Save Plan

Read `${CLAUDE_SKILL_DIR}/templates/AP-n.md.template`, fill in all fields from phase outputs, write to `docs/plans/AP-{N}.md`.

## Phase 7: Lessons Learned

Read `AGENTS.md`, append new one-line discoveries to the `## Lessons Learned` section. No duplicates.

## Phase 8: Update Docs

Run the equivalent of `/ap-update-docs` inline: scan README.md, AGENTS.md, and other project docs. Update anything made stale by the implementation. Do NOT touch Lessons Learned or Architecture Decisions (already handled in Phase 7). Skip if no docs need changes.

## Phase 9: Insights

Always print, even on partial runs. Label the line with "Insights:" then:
- File count and plan number
- One bullet per modified file with what changed
- Any lessons added
