---
type: "prompt"
description: "Stage transition prompt — validates Develop completion and initiates Deliver stage"
version: "1.0.0"
updated: "2026-02-02"
scope: "deliver"
usage: "Run at start of Deliver stage to transition from Develop"
---

# Start Deliver Stage

## Purpose

Transition from Develop to Deliver. Validates prerequisites, updates state, loads context, and conducts intake validation with human confirmation before proceeding.

---

## Prompt

You are transitioning this project from Develop to Deliver stage.

## Step 1: Validate Prerequisites

Read and verify:
- status.md — Confirm stage is Develop and phase is complete
- README.md — Confirm documentation exists and is complete
- Test suite — Confirm tests pass (95%+ rate)
- Deliverable — Confirm artifact builds/runs successfully

**CRITICAL — Missing Resources:**
If any expected file is missing (e.g., ADF-DELIVER-SPEC.md referenced but not found):
- STOP immediately
- Report exactly what is missing
- Ask the user to provide it
- Do NOT assume you lack access — the user may have forgotten to copy it
- Do NOT skip and move on

If prerequisites are NOT met:
- STOP
- Report what's missing or incomplete
- Do not proceed until Develop exit criteria are satisfied

If prerequisites ARE met, continue to Step 2.

## Step 2: Update State

Update status.md:
- stage: deliver
- phase: intake
- last_action: "Transitioned from Develop"
- next_steps: "Conducting intake validation"

## Step 3: Load Context

Read and internalize:
- The deliverable — What was built (code, workflow, artifact, etc.)
- README.md — Usage instructions, setup, configuration
- design.md — Technical specification (for validation reference)
- discover-brief.md — Reference for success criteria

Note the project classification (type + modifiers) from Brief.

## Step 4: Intake Validation

**HARD GATE: Do NOT proceed to Delivery Capability Assessment or Planning until human confirms understanding.**

Your goal: Verify Develop outputs are present and understand what needs to be delivered.

### 4a. Verify Develop Outputs

Quick checklist (smell test, not exhaustive review):
- [ ] Deliverable exists and builds/runs
- [ ] Documentation exists (README, usage guides)
- [ ] Tests exist and pass (95%+)
- [ ] No uncommitted changes
- [ ] No obvious gaps or blockers

**This is NOT a full review.** Develop already did thorough validation. This is a handoff verification: "I have what I need to proceed."

If anything is missing or broken, STOP and report to human.

### 4b. Understand What Was Built

Provide a clear summary:
- What the deliverable is (2-3 sentences)
- What it does (core functionality)
- Current state (works locally, needs deployment, etc.)

### 4c. Determine Delivery Scope

**Project-type specific assessment:**

- **Artifact:** Simple export/distribution
  - Questions: Where does it go? What format? Who accesses it?
- **App (feature):** Deploy to existing production environment
  - Questions: Where's production? How do we deploy? CI/CD?
- **App (MVP):** First-time infrastructure setup + deployment
  - Questions: Where to host? Domain? Database? Full setup needed?
- **Workflow:** Installation/activation in target environment
  - Questions: Where to install? How to activate? Configuration?

**Identify delivery target NOW (after understanding scope):**
- Where is this going? (Railway, Vercel, local, export location, etc.)
- First-time setup or existing environment?
- Who's the end user and how do they access it?

### 4d. Surface Open Items

Check README, design.md, or status.md for:
- "Notes for Deliver" or "Deployment notes"
- Open questions or deferred items
- Any deployment-specific decisions needed

**Walk through EACH open item individually.** Do NOT batch defaults together.

For each open item:
1. State the item clearly
2. Ask user to decide, OR propose a default and ask for confirmation
3. Wait for response before moving to next item

### 4e. Ask Clarifying Questions

Use AskUserQuestion or direct questions for:
- Deployment target — "Where should this be deployed?"
- Access — "Who needs access and how?"
- Credentials — "Do we have hosting account credentials?"
- Domain — "Custom domain needed?"
- Environment — "Production-only or staging first?"

Ask in batches of 2-4 questions. Continue until all ambiguities resolved.

### 4f. Self-Validation Checkpoint

**Before asking to proceed, perform this self-check:**

- Have I verified all Develop outputs are present?
- Do I understand what was built and what it does?
- Do I know where it's being deployed/distributed?
- Are there ANY remaining questions about delivery target or approach?

If the answer to any is "no" or "unclear" — go back and ask. Do NOT ask to proceed until you have full clarity.

### 4g. Confirm Understanding

When you believe you have full clarity, state:

"I have verified Develop outputs and understand the delivery scope:
- [What was built - 1 sentence]
- [Delivery target - Railway, export, etc.]
- [Scope - MVP setup, feature deploy, simple export]
- [Open items addressed or questions asked]

Ready to proceed to Delivery Capability Assessment. Confirm?"

**WAIT for human confirmation before proceeding.**

Do NOT:
- Proceed to capability assessment without explicit confirmation
- Start writing plan.md or tasks.md
- Assume silence means approval

## Step 5: Proceed to Planning Phases (2-3)

Only after human confirms understanding:

1. Update status.md phase to: delivery-capability-assessment
2. Draft manifest.md (deployment dependencies)
3. Draft capabilities.md (skills/tools for deployment/testing) — **you MUST read** `~/code/_shared/capabilities-registry/INVENTORY.md` first. Include a **Registry Summary** section at the top of capabilities.md showing: registry path, total available, matched capabilities, and gaps. A missing Registry Summary means Phase 2 is incomplete.
4. Present capability assessment for approval
5. Then proceed to Delivery Planning phase (plan.md + tasks.md)

Planning artifacts go in `docs/adf/` per ADF-FOLDER-STRUCTURE-SPEC.md, except `tasks.md` which may be at `docs/tasks.md` (cross-stage) per ADF-TASKS-SPEC.md.

## Step 6: Proceed to Review & Approval (Phase 4)

**After Phase 3 (Planning), proceed to Review Loop.**

Unlike Develop's HARD GATE placement, Deliver uses the correct pattern:
1. Complete planning (manifest, capabilities, plan, tasks)
2. Run internal review (Ralph Loop) on planning artifacts
3. Run external review (user-driven, optional)
4. **THEN present reviewed artifacts to human for approval**

**Phase 4 sequence:**
1. Run internal review via Ralph Loop (see deliver-ralph-review-prompt.md)
2. Optionally run external review (user decides)
3. Present all planning artifacts to human:
   - manifest.md
   - capabilities.md
   - plan.md
   - tasks.md
   - Review summary (issues resolved, reviewer feedback)

**⛔ DO NOT proceed to execution phases. DO NOT start infrastructure setup. DO NOT start deployment.**

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
1. Infrastructure Setup (if needed — skip for simple Artifacts)
2. Deployment Execution (deploy/distribute to target)
3. Validation & Testing (3-tier: automated, browser, manual)
4. Milestone Closeout (cleanup, access docs, THE SEAL)

**Testing model (three-tier):**
- **Tier 1: Automated** — API tests, integration tests, E2E tests in production. Run first. 95%+ pass rate required.
- **Tier 2: Browser/Agent** — Interactive testing via browser automation tool (runtime-specific, e.g., Claude in Chrome), MCP Inspector. Run after Tier 1 passes.
- **Tier 3: Manual** — User acceptance testing. Run after Tier 2 passes. See `kb/MANUAL-TESTING-GUIDE.md`.
- Document results in `docs/adf/test-results.md`.

**Progressive testing:** Tier 1 must pass before Tier 2 begins. Tier 2 must pass before Tier 3 begins. Issues found in later tiers require re-testing from Tier 1.

---

## Phase Sequence (For Reference)

**PLANNING PHASES (1-3)** — Produce artifacts:
1. **Intake & Readiness Check** ← YOU ARE HERE (requires human confirmation to exit)
2. Delivery Capability Assessment (produces manifest.md + capabilities.md)
3. Delivery Planning (produces plan.md + tasks.md)

**REVIEW & APPROVAL (Phase 4)** — Review artifacts, then human approval:
4. Review Loop & Approval (internal review → external review → human approval)

**✅ HARD GATE: After Phase 4 review, STOP. Present reviewed planning artifacts for human approval.**
**DO NOT proceed to execution until human explicitly approves.**

**EXECUTION PHASES (5-8)** — Require explicit human approval of reviewed planning artifacts:
5. Infrastructure Setup (if needed for MVPs or first-time deployments)
6. Deployment Execution (deploy/distribute to target environment)
7. Validation & Testing (3-tier testing model)
8. Milestone Closeout (cleanup, access docs, THE SEAL)

Do NOT skip phases. Each phase has an exit gate.
Planning and execution are separate workflows — complete all planning first, review it, THEN execute.
**Between each phase:** Run phase boundary protocol (update status → /clear → re-read → confirm).

---

## Notes

- Intent.md is already loaded via Context File (CLAUDE.md/AGENTS.md)
- Deliverable from Develop is primary input (fully loaded and tested)
- Design is REFERENCED (for validation)
- Brief is REFERENCED (for success criteria verification)
- Simple Artifacts may skip Infrastructure Setup (Phase 5)
- If resources are missing, STOP and ask — don't skip
