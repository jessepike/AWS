---
type: "specification"
description: "Defines the two-phase review mechanism used across all ADF stages"
version: "1.2.0"
updated: "2026-01-31"
scope: "adf"
lifecycle: "reference"
location: "adf/ADF-REVIEW-SPEC.md"
---

# ADF Review Specification

## Purpose

Define the review mechanism that applies across all ADF stages. This spec owns the **how** of reviews — cycle rules, severity definitions, stop conditions, issue logging, and tool requirements. Stage-specific prompts own the **what** — review dimensions, files to read, and artifact-specific criteria.

---

## Two-Phase Model

Every stage that produces a reviewable artifact uses a two-phase review process:

| Phase | Name | Mechanism | Required? |
|-------|------|-----------|-----------|
| **Phase 1** | Internal Review | Ralph Loop plugin — automated self-review cycle | **Mandatory** for all stages |
| **Phase 2** | External Review | User-initiated — external models or fresh-perspective agents | **User-driven** — based on complexity and project type |

### Phase 1: Internal Review

An automated iterative review. The reviewing agent reads the artifact, finds issues, fixes them, and re-reviews until the artifact is clean.

**Tool requirement:** MUST use the Ralph Loop plugin (`/ralph-loop:ralph-loop`).

**Prompt assembly:** The Ralph Loop is invoked with the stage-specific review prompt from `adf/prompts/`. The prompt contains the review dimensions; this spec defines the mechanism the prompt operates within.

**Invocation pattern:**
```bash
/ralph-loop:ralph-loop "$(cat ~/code/_shared/adf/prompts/{stage-prompt}.md)" --max-iterations 10 --completion-promise "{STAGE_PROMISE}"
```

### Phase 2: External Review

A fresh-perspective review by external models or agents not involved in Phase 1. The user decides whether to run Phase 2 and how many reviewers to use.

**When to use Phase 2:**
- Complex or multi-component projects
- Commercial-scale projects
- Projects where the stakes of a missed issue are high
- When the user requests it

**When Phase 2 can be skipped:**
- Simple or low-complexity projects
- Internal-only artifacts
- When the user explicitly decides it's not needed

**The user always makes this call.** Agents do not decide to skip or include Phase 2 on their own.

---

## Cycle Rules

These rules apply to both Phase 1 and Phase 2.

### Minimum Cycles

- **Phase 1:** Minimum 2 review cycles. Always.
- **Phase 2:** Minimum 1 cycle per reviewer (if Phase 2 is conducted).

### Stop Conditions

After each review cycle, assess:

> "Did this cycle surface any Critical or High severity issues?"

- **If yes:** Fix issues, run another cycle.
- **If no (and minimum met):** Review phase is complete.

### Maximum Cycles

- **Hard maximum:** 10 cycles per phase.
- **Structural problem signal:** If past 4 cycles and still finding Critical issues, something is fundamentally wrong. Stop and flag for human input.
- **Stuck signal:** If the same issue persists for 3+ iterations, stop and flag for human input.

### Typical Ranges

| Project Complexity | Phase 1 (Internal) | Phase 2 (External) |
|--------------------|---------------------|---------------------|
| Simple / Artifact | 2-3 cycles | 1 round (if conducted) |
| Moderate / App (personal) | 2-4 cycles | 1-2 rounds |
| Complex / App (commercial) | 3-5 cycles | 2-3 rounds |
| Workflow | 2-4 cycles | 1-2 rounds |

---

## Severity Definitions

Used consistently across all stages and both phases.

| Severity | Definition | Action |
|----------|------------|--------|
| **Critical** | Must resolve. Blocks the next stage or is fundamentally flawed. | Fix before proceeding. |
| **High** | Should resolve. Significant gap or weakness. | Fix before proceeding. |
| **Low** | Minor. Polish, cosmetic, or implementation detail. | Log but do not spend cycles fixing. |

**The test for Critical/High:** "If this issue isn't fixed, will the project fail or be significantly worse?" If no, it's Low.

---

## Complexity Assessment

After severity classification, assess the **effort required to fix** each Critical/High issue.

| Complexity | Definition | Examples |
|-----------|------------|----------|
| **Low** | Direct edit, no research, clear fix | Change endpoint ID, add missing field to spec, fix typo in schema |
| **Medium** | Requires design thinking, small refactor, clear path forward | Redesign cursor logic, add table columns + update data flow, restructure section |
| **High** | Needs research, investigation, architectural rethinking | Evaluate alternative architectures, spike on unknown API behavior, resolve conflicting requirements |

**Purpose:** Complexity guides **action-taking**. Low/Medium complexity issues are fixed automatically. High complexity issues are surfaced to the user for investigation.

---

## Action-Taking Matrix

Once issues are classified by severity and complexity, take action according to this matrix:

| Severity | Complexity | Action |
|----------|-----------|--------|
| **Critical** | Low | Fix automatically — direct edit, no user approval needed |
| **Critical** | Medium | Fix automatically — apply design thinking, implement clear path |
| **Critical** | High | **Flag for user** — needs research, investigation, or architectural discussion |
| **High** | Low | Fix automatically — direct edit, no user approval needed |
| **High** | Medium | Fix automatically — apply design thinking, implement clear path |
| **High** | High | **Flag for user** — needs research, investigation, or architectural discussion |
| **Low** | Any | Log only — do not spend cycles fixing |

### Auto-Fix Guidelines

When fixing automatically (Critical/High + Low/Medium complexity):
- Apply the minimal fix that resolves the issue
- Update related sections for consistency (e.g., if changing a schema, update data flow descriptions)
- Do not expand scope beyond the identified issue
- Log the fix in the Issue Log with source attribution and resolution

### User Flag Guidelines

When flagging for user (Critical/High + High complexity):
- Clearly state the issue and why it's blocking
- Identify what research or investigation is needed
- Propose 2-3 potential approaches if possible
- Wait for user decision before proceeding

---

## Issue Logging

All issues are logged in the artifact's Issue Log section using this format:

| # | Issue | Source | Severity | Complexity | Status | Resolution |
|---|-------|--------|----------|------------|--------|------------|
| N | [description] | [source] | Critical/High/Low | Low/Medium/High/N/A | Open/Resolved/Deferred | [resolution or -] |

**Complexity column:**
- For Critical/High issues: specify Low/Medium/High to indicate fix effort
- For Low severity issues: use N/A (not fixing, so complexity is irrelevant)

### Source Attribution

| Source Value | Meaning |
|--------------|---------|
| `Ralph-Internal` | Phase 1 internal review (Discover) |
| `Ralph-Design` | Phase 1 internal review (Design) |
| `Ralph-Develop` | Phase 1 internal review (Develop) |
| `External-{Model}` | Phase 2 external review (e.g., `External-GPT4`, `External-Gemini`) |
| `External-{Lens}` | Phase 2 agent review with named perspective (e.g., `External-Pragmatic`) |
| `Human` | Human-identified issue |

### Phase Completion Entry

When a review phase completes, add a summary entry:

| # | Issue | Source | Severity | Complexity | Status | Resolution |
|---|-------|--------|----------|------------|--------|------------|
| N | Phase {1/2} review complete | {source} | - | - | Complete | {cycle count}: {issues found} Critical, {n} High resolved |

---

## Review Log

In addition to the Issue Log, each reviewable artifact MUST include a **Review Log** section that captures the review process narrative.

### Purpose

The Review Log provides a chronological record of what happened during reviews — what was found, what actions were taken, and the outcome. This transparency helps:
- Track the review process over time
- Understand what issues were addressed and how
- Provide context for future maintainers
- Document cross-reviewer consensus

### Location

Place the Review Log section immediately after the Issue Log and before the Revision History.

### Format

```markdown
## Review Log

### Phase {1/2}: {Internal/External} Review

**Date:** YYYY-MM-DD
**Mechanism/Reviewers:** {Ralph Loop N cycles | External-Model1, External-Model2}
**Issues Found:** {N} Critical, {N} High, {N} Low
**Complexity Assessment:** {N} Low, {N} Medium, {N} High (for Critical/High issues only)
**Actions Taken:**
- **Auto-fixed ({N} issues):**
  - {Issue description} ({Severity}/{Complexity}) — {What was done}
  - {Issue description} ({Severity}/{Complexity}) — {What was done}
- **Flagged for user ({N} issues):**
  - {Issue description} ({Severity}/High) — {What needs investigation}
- **Logged only ({N} issues):**
  - {Issue description} (Low/N/A) — {Why deferred}

**Cross-Reviewer Consensus:** (Phase 2 only)
- {Issues flagged by multiple reviewers and how weighted}

**Outcome:** {Phase complete/incomplete, what happens next}
```

### Required Fields

| Field | Description |
|-------|-------------|
| **Date** | ISO date (YYYY-MM-DD) when review phase occurred |
| **Mechanism/Reviewers** | Phase 1: "Ralph Loop (N cycles)"; Phase 2: Comma-separated reviewer sources |
| **Issues Found** | Count by severity (Critical, High, Low) |
| **Complexity Assessment** | Count by complexity (Low, Medium, High) for Critical/High issues only |
| **Actions Taken** | Grouped by action type (auto-fixed, flagged, logged) with severity/complexity and brief description of resolution |
| **Cross-Reviewer Consensus** | Phase 2 only: Note which issues had consensus and how they were weighted |
| **Outcome** | Status and next steps (e.g., "Phase 2 complete, design approved for Develop") |

### When to Update

- **After Phase 1 completes:** Add Phase 1 entry
- **After Phase 2 completes:** Add Phase 2 entry
- **During multi-cycle reviews:** Update the entry after each cycle if significant new issues are found

---

## YAGNI Enforcement

Every review — internal and external — MUST apply YAGNI rigorously:

- Only flag issues that **block or significantly harm** the next stage
- Do NOT suggest features, additions, or "nice to haves"
- Do NOT ask "what about X?" unless X is critical to stated goals
- If something is explicitly out of scope, respect that decision
- Do NOT backdoor scope expansion as "questions to consider"
- Low-impact issues should not consume review cycles

**Reviewers are not consultants.** Their job is to find problems, not generate ideas.

---

## Completion Behavior

### Phase 1 Completion

When Phase 1 stop conditions are met:

1. Update the artifact's frontmatter status to `internal-review-complete`
2. Increment the `review_cycle` count in frontmatter
3. Add phase completion entry to Issue Log
4. Output the stage-specific completion promise

**Completion promises by stage:**

| Stage | Promise |
|-------|---------|
| Discover | `INTERNAL_REVIEW_COMPLETE` |
| Design | `DESIGN_INTERNAL_REVIEW_COMPLETE` |
| Develop | `DEVELOP_INTERNAL_REVIEW_COMPLETE` |

### Phase 2 Completion

When Phase 2 stop conditions are met (or user decides to skip):

1. Update the artifact's frontmatter status to `complete`
2. Add phase completion entry to Issue Log
3. Log any Design/Develop questions forwarded to next stage
4. Update revision history

### External Feedback Processing

After receiving Phase 2 feedback:

1. **Filter aggressively** — Ignore suggestions that expand scope
2. **Extract blocking issues** — Only issues that genuinely block the next stage
3. **Assess severity** — Apply Critical/High/Low definitions
4. **Cross-reference reviewers** — If only one flags it and it's not clearly blocking, it's probably not Critical/High
5. **Consensus weighting** — Issues flagged by multiple reviewers are weighted higher
6. **Assess complexity** — For each Critical/High issue, determine Low/Medium/High fix effort
7. **Take action** — Apply the action-taking matrix (auto-fix Low/Medium, flag High to user)
8. **Log all issues** — Record in Issue Log with source attribution, severity, complexity, and resolution

---

## Stage-Specific Prompt Structure

Each stage has two prompts in `adf/prompts/`:

| Stage | Internal Prompt | External Prompt |
|-------|-----------------|-----------------|
| Discover | `ralph-review-prompt.md` | `external-review-prompt.md` |
| Design | `design-ralph-review-prompt.md` | `design-external-review-prompt.md` |
| Develop | `develop-ralph-review-prompt.md` | `develop-external-review-prompt.md` |

**Prompts reference this spec for mechanism.** They should NOT duplicate cycle rules, severity definitions, stop conditions, or YAGNI enforcement. They contain only:

- Stage context (what phase this is, what comes next)
- Files to read
- Review dimensions (what to check)
- Artifact to update
- Type-specific modules (App, Workflow, Artifact)
- Completion promise string

### Type-Specific Modules

Review prompts include optional modules based on project classification:

| Module | Applies When | Adds |
|--------|-------------|------|
| **Commercial** | `Scale: commercial` | Revenue/cost alignment, market assumptions |
| **Workflow** | `Type: Workflow` | Trigger gaps, failure modes, idempotency |
| **Artifact** | `Type: Artifact` | Source dependencies, format compliance |
| **App** | `Type: App` | Scalability fit, state management, error handling |

Modules are appended to the base prompt, not separate files.

---

## Relationship to Other Specs

| Spec | Relationship |
|------|-------------|
| ADF-STAGES-SPEC.md | Defines the stages; this spec defines the review mechanism within stages |
| ADF-BRIEF-SPEC.md | Defines the Brief artifact; this spec defines how Briefs are reviewed |
| ADF-ARCHITECTURE-SPEC.md | Validation primitive; reviews are one form of validation |

---

## Design Principles

- **Mechanism is universal** — same cycle rules, severity, stop conditions everywhere
- **Dimensions are specific** — what you check depends on what you're reviewing
- **Internal is mandatory, external is user-driven** — agents don't decide review depth
- **YAGNI is non-negotiable** — reviewers find problems, not opportunities
- **Tool is prescribed** — Ralph Loop plugin, not ad-hoc agent invocations
- **Action follows assessment** — severity + complexity determine whether to auto-fix or flag for user

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-30 | Initial spec — two-phase model, severity definitions, cycle rules |
| 1.1.0 | 2026-01-31 | Added complexity assessment and action-taking matrix for external review processing |
| 1.2.0 | 2026-01-31 | Added Review Log section requirement for capturing review process narrative |
