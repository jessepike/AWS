---
type: "prompt"
description: "Stage transition prompt — validates Design completion and initiates Develop stage"
version: "2.2.0"
updated: "2026-02-02"
scope: "develop"
usage: "Run at start of Develop stage to transition from Design"
---

# Start Develop Stage

## Purpose

Transition from Design to Develop. Validates prerequisites, updates state, loads context, and conducts intake validation with human confirmation before proceeding.

---

## Prompt

You are transitioning this project from Design to Develop stage.

## Step 1: Validate Prerequisites

Read and verify:
- status.md — Confirm stage is Design and phase is complete
- design.md — Confirm status is complete, no open P1 issues
- Any supporting design docs (architecture.md, etc.) if referenced

**CRITICAL — Missing Resources:**
If any expected file is missing (e.g., ADF-DEVELOP-SPEC.md referenced but not found):
- STOP immediately
- Report exactly what is missing
- Ask the user to provide it
- Do NOT assume you lack access — the user may have forgotten to copy it
- Do NOT skip and move on

If prerequisites are NOT met:
- STOP
- Report what's missing or incomplete
- Do not proceed until Design exit criteria are satisfied

If prerequisites ARE met, continue to Step 2.

## Step 2: Update State

Update status.md:
- stage: develop
- phase: intake
- last_action: "Transitioned from Design"
- next_steps: "Conducting intake validation"

## Step 3: Load Context

Read and internalize:
- design.md — Your primary input (the technical specification)
- Any supporting design docs (architecture.md, data-model.md, etc.)
- discover-brief.md — Reference for success criteria

Note the project classification (type + modifiers) from Brief.

## Step 4: Intake Validation

**HARD GATE: Do NOT proceed to Capability Assessment or Planning until human confirms understanding.**

Your goal: Ensure 100% understanding of the design before any implementation work.

### 4a. Summarize Understanding

Provide a clear summary:
- What we're building (2-3 sentences)
- Key technical choices from design
- Success criteria from Brief

### 4b. Surface Open Items

Check design.md for:
- "Notes for Develop" or "Questions for Develop" sections
- Open questions or deferred items
- Any P2/P3 issues that need decisions

**Walk through EACH open item individually.** Do NOT batch defaults together.

For each open item:
1. State the item clearly
2. Ask user to decide, OR propose a default and ask for confirmation
3. Wait for response before moving to next item

Example (WRONG): "I found 4 open items. Want me to use defaults for all?"
Example (RIGHT): "Open item 1: Light theme tokens are unspecified. Should I derive from dark theme, or do you have specific colors?"

### 4c. Ask Clarifying Questions

Use AskUserQuestion or direct questions for:
- Technical choices — "The design specifies X. Is this confirmed?"
- Ambiguities — "This section is unclear. What did you intend?"
- Dependencies — "This requires Y. Is it available?"
- Priorities — "If we hit constraints, what's negotiable?"

Ask in batches of 2-4 questions. Continue until all ambiguities resolved.

### 4d. Self-Validation Checkpoint

**Before asking to proceed, perform this self-check:**

- Have I resolved ALL open items from design.md?
- Are there ANY remaining ambiguities I haven't asked about?
- Is there ANYTHING else I need to know before building?

If the answer to any is "yes" — go back and ask. Do NOT ask to proceed until you've exhausted your questions.

### 4e. Confirm Understanding

When you believe you have full clarity, state:

"I have full understanding of the design:
- [1-2 sentence summary]
- [Key decisions resolved]
- [Open items addressed]

Ready to proceed to Capability Assessment. Confirm?"

**WAIT for human confirmation before proceeding.**

Do NOT:
- Proceed to capability assessment without explicit confirmation
- Start writing plan.md or tasks.md
- Assume silence means approval

## Step 5: Proceed to Planning Phases (2-3)

Only after human confirms understanding:

1. Update status.md phase to: capability-assessment
2. Draft manifest.md (dependencies)
3. Draft capabilities.md (skills/tools/agents) — **you MUST read** `~/code/_shared/capabilities-registry/INVENTORY.md` first. Include a **Registry Summary** section at the top of capabilities.md showing: registry path, total available, matched capabilities, and gaps. A missing Registry Summary means Phase 2 is incomplete.
4. Present capability assessment for approval
5. Then proceed to Planning phase (plan.md + tasks.md)

Planning artifacts go in `docs/adf/` per ADF-FOLDER-STRUCTURE-SPEC.md, except `tasks.md` which may be at `docs/tasks.md` (cross-stage) per ADF-TASKS-SPEC.md.

## Step 6: Proceed to Review & Approval (Phase 4)

**After Phase 3 (Planning), proceed to Review Loop.**

Unlike the old pattern, Develop now uses the correct gate ordering:
1. Complete planning (manifest, capabilities, plan, tasks)
2. Run internal review (Ralph Loop) on planning artifacts
3. Run external review (user-driven, optional)
4. **THEN present reviewed artifacts to human for approval**

**Phase 4 sequence:**
1. Run internal review via Ralph Loop (see develop-ralph-review-prompt.md)
2. Optionally run external review (user decides)
3. Present all planning artifacts to human:
   - manifest.md
   - capabilities.md
   - plan.md
   - tasks.md
   - Review summary (issues resolved, reviewer feedback)

**⛔ DO NOT proceed to execution phases. DO NOT start environment setup. DO NOT start building.**

Wait for explicit human approval: "Approved" or equivalent.

If the human has feedback, iterate on planning artifacts. Do not move forward until they approve.

## Step 7: Proceed to Execution Phases (5-8)

**PREREQUISITE: Human has explicitly approved all planning artifacts from Step 6.**

If you do not have explicit human approval, STOP and ask for it.

**Phase boundary protocol:** At each phase transition:
1. Update the Handoff block in tasks.md (phase, status, next, done this phase, next phase requires)
2. Update status.md with phase completion summary
3. Commit all changes
4. Run `/clear` to reset context
5. Re-read: Context (CLAUDE.md/AGENTS.md) → status.md → tasks.md (handoff block first) → plan.md
6. Confirm: "Phase N complete. Starting Phase N+1. Here's what I see: [summary from handoff]"

Execution phases:
1. Environment Setup — Install dependencies, configure capabilities
2. Build — Implement per tasks.md with TDD, then verify build matches design
3. Documentation — README, API docs, usage guides as appropriate
4. Closeout — Artifact lifecycle, commit verification, status.md update (THE SEAL)

**Testing model (three-tier):**
- **Tier 1: Automated** — Unit, integration, E2E via test frameworks. Run during build.
- **Tier 2: Browser/Real-world** — Interactive testing in browser/inspector. Run after Tier 1 passes.
- **Tier 3: Manual** — User acceptance, edge cases, subjective validation. Run after Tier 2 passes. See `kb/MANUAL-TESTING-GUIDE.md`.
- All three tiers required for all project types. Plan must specify approach per tier (see ADF-DEVELOP-SPEC.md).

**Build-to-design verification:** Before exiting Phase 6, verify every design requirement has a corresponding implementation + test. Document coverage in tasks.md.

---

## Phase Sequence (For Reference)

**PLANNING PHASES (1-3)** — Produce artifacts:
1. **Intake & Validation** ← YOU ARE HERE (requires human confirmation to exit)
2. Capability Assessment (produces manifest.md + capabilities.md)
3. Planning (produces plan.md + tasks.md)

**REVIEW & APPROVAL (Phase 4)** — Review artifacts, then human approval:
4. Review Loop & Approval (internal review → external review → human approval)

**✅ HARD GATE: After Phase 4 review, STOP. Present reviewed planning artifacts for human approval.**
**DO NOT proceed to execution until human explicitly approves.**

**EXECUTION PHASES (5-8)** — Require explicit human approval of reviewed planning artifacts:
5. Environment Setup
6. Build (includes build-to-design verification)
7. Documentation (README, API docs, usage guides)
8. Closeout (artifact lifecycle, commit verification, THE SEAL)

Do NOT skip phases. Each phase has an exit gate.
Planning and execution are separate workflows — complete all planning first.
**Between each phase:** Run phase boundary protocol (update status → /clear → re-read → confirm).

---

## Notes

- Intent.md is already loaded via Context File (CLAUDE.md/AGENTS.md)
- Design is CONSUMED in Develop (fully loaded and processed)
- Brief is REFERENCED (for success criteria verification)
- Updates to design docs during Develop: document and move on, no re-review needed
- If resources are missing, STOP and ask — don't skip
