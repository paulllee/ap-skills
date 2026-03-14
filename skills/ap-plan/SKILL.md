---
name: ap-plan
description: "Run the AP-n agentic planning workflow: research, propose, peer-review, user decision, test-first, implement with subagents, code review, performance testing."
argument-hint: "(feature or problem description)"
disable-model-invocation: true
allowed-tools: Bash Read Write Edit Glob Grep Agent EnterPlanMode ExitPlanMode TaskCreate TaskGet TaskUpdate TaskList
---

# AP-Plan

Run the AP-n planning cycle for: **$ARGUMENTS**

Follow all phases in order. Do not implement before user approval. Track progress with the task list, updating after each phase. No commits. Detect shell before Bash calls — on PowerShell use the `.ps1` variants of scripts below.

## Script helpers

Plan-specific scripts live in `${CLAUDE_SKILL_DIR}/bin/`. Shared scripts live in `${CLAUDE_SKILL_DIR}/../ap-lib/bin/`.

- **ap-next-plan.sh / .ps1** — Creates `docs/plans/` if needed, finds the next AP-N number, creates the file, prints the absolute path to stdout.
- **ap-status.sh / .ps1** — Parses all existing AP-*.md plans and prints one line per plan: `path | title | date | status`.
- **append-lessons.sh / .ps1** — Appends a lesson to `## Lessons Learned` in AGENTS.md with deduplication. Usage: `append-lessons.sh "lesson text"`. Exits 2 if duplicate.
- **list-docs.sh / .ps1** — Lists documentation files with line counts. Output: `path | size_lines` per line.

## Pre-flight

1. Run `bash "${CLAUDE_SKILL_DIR}/bin/ap-next-plan.sh"` → capture the output as `PLAN_FILE`.
2. Run `bash "${CLAUDE_SKILL_DIR}/bin/ap-status.sh"` to display existing plans for context.
3. Create a task list with all phases (1-4, 4.5, 5-9).
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

Before implementing, write the plan to `PLAN_FILE` (captured in Pre-flight). Read `${CLAUDE_SKILL_DIR}/templates/AP-n.md.template`, fill it from the phase outputs collected so far (set Status to **In Progress**), and write to `PLAN_FILE`. Additionally fill in:

- **Acceptance Criteria** — concrete, testable requirements derived from the chosen approach
- **Implementation Steps** — numbered work units with: description, files involved, dependencies on other steps
- **Performance Criteria** — what to benchmark (e.g. "API response time under 200ms"), or "N/A"

This ensures subagents can reference the plan during implementation.

## Phase 5: Test First

1. Launch 1 Agent subagent: "Read `PLAN_FILE` acceptance criteria. Read AGENTS.md for test framework/conventions. Write two categories of tests: (a) **Unit tests** — one per acceptance criterion, testing individual components; (b) **Integration tests** — testing components working together end-to-end. Tests should compile/parse but fail (no implementation exists yet)."
2. Run the project's test command to verify tests parse correctly.
3. If parse errors, send errors back to agent for one fix pass.
4. Update `PLAN_FILE` → fill Test Plan section with test files created and what each tests.

## Phase 6: Implement

1. Read Implementation Steps from `PLAN_FILE`.
2. **Parallelism decision:** Check if steps have file-level dependencies on each other.
   - Independent steps → launch parallel Agent subagents, each with `isolation: "worktree"`
   - Dependent steps → group into a single agent
3. Each agent prompt: "Read `PLAN_FILE` for full context. Implement step(s) [X]. Run **unit tests** relevant to your step after each change. Read AGENTS.md for conventions. Max 3 test-fix iterations. Report final status (pass/fail, files modified) when done."
4. Create one task per implementation step for coordination.
5. If any agent reports failure after 3 iterations, flag for user attention before continuing.

## Phase 6.5: Integration (Janitor)

Runs after all Phase 6 agents complete.

Launch 1 Agent subagent: "Read `PLAN_FILE`. All implementation steps are complete. Your job: (1) If parallel worktrees were used, verify the merged result is coherent. (2) Run the **full test suite** (unit + integration tests from Phase 5). (3) Fix any integration issues — tests that pass individually but fail together. (4) Run lint/format commands from AGENTS.md. (5) Max 3 fix iterations. Report final test results and any remaining failures."

If integration tests still fail after 3 iterations, flag for user attention.

## Phase 7: Code Review (Hard Gate)

1. Launch 1 Agent subagent: "Read `PLAN_FILE` and all modified files. Review for: correctness, adherence to plan requirements, code quality, AGENTS.md conventions. Tag each finding as `blocking` or `suggestion`."
2. **Hard gate logic:**
   - If blocking findings → launch fix Agent with review feedback → re-review once
   - If still blocking after re-review → report remaining issues to user, do not proceed automatically
   - If no blocking findings → proceed to next phase
3. Update `PLAN_FILE` → fill Code Review section with findings and resolution status.

## Phase 8: Performance Testing

1. Skip if Performance Criteria in plan is "N/A".
2. Launch 1 Agent subagent: "Read `PLAN_FILE` performance criteria. Write benchmarks for the implementation. Run them. Report: what was measured, results, whether criteria were met."
3. Update `PLAN_FILE` → fill Performance Results section.

## Phase 9: Wrap-up

1. **Update plan:** Re-read `PLAN_FILE`, fill in Implementation Notes and Files Modified, set Status to **Complete**, and write back.
2. **Lessons learned:** For each lesson, run `bash "${CLAUDE_SKILL_DIR}/../ap-lib/bin/append-lessons.sh" "lesson text"`. The script handles deduplication.
3. **Update docs:** Run `bash "${CLAUDE_SKILL_DIR}/../ap-lib/bin/list-docs.sh"` to find docs. Update anything stale from implementation. Do NOT touch Lessons Learned or Architecture Decisions. Skip if nothing changed.
4. **Insights** — always print. Label "Insights:" then: file count and plan number, one bullet per modified file with what changed, any lessons added, test results summary, performance results summary.

## Troubleshooting

- **No `docs/plans/` directory:** The scripts create it automatically.
- **Agent subagent timeout:** Retry once with a narrower focus area, then proceed with available findings.

## Examples

- `/ap-plan add user authentication`
- `/ap-plan fix flaky integration tests`
