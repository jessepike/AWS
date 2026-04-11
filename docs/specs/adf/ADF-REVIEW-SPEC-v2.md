---
type: "specification"
description: "Defines the review mechanism — internal self-review and optional external review"
version: "2.0.0"
updated: "2026-03-23"
scope: "adf"
lifecycle: "active"
supersedes: "ADF-REVIEW-SPEC v1.2.0"
---

# ADF Review Specification v2

## Purpose

Define the review mechanism that applies across all ADF stages. This spec owns the **how** — cycle rules, severity definitions, stop conditions, and issue logging. Stage-specific prompts own the **what** — review dimensions and artifact-specific criteria.

---

## Internal Review (Mandatory)

An automated iterative self-review cycle embedded in every stage exit. The reviewing agent reads the artifact, identifies issues, fixes what can be fixed immediately, and re-reviews until clean.

**Mechanism:** Embedded self-review (not delegated to external agents).

**Cycle rules:**
- Minimum 2 cycles, always
- Maximum 10 cycles per stage
- Stop when: no Critical/High issues found AND minimum cycles met
- Stop early if: same issue persists 3+ iterations (flag to user)

---

## External Review (Optional, Risk-Driven)

Fresh-perspective review by external models or agents, triggered by the user based on project complexity and risk tolerance. The user decides whether to run Phase 2, not agents.

**When to run:**
- Complex or multi-component projects
- Projects with high stakes for missed issues
- When user explicitly requests it

**When to skip:**
- Simple or low-complexity projects
- When user explicitly decides it's not needed

**Multi-model requirement:** When external review is run, it MUST include at least one non-Claude model (GPT via Codex, Gemini, etc.). Claude reviewing Claude catches surface issues but shares blind spots. Different model families find genuinely different problems. Run Claude -p AND GPT (via `codex exec`) as separate review passes — do not substitute one for the other.

**Source values:** `External-Claude`, `External-GPT`, `External-Gemini`, `Human`.

---

## Severity Definitions

Consistent across all stages and both review types.

| Severity | Definition | Implication |
|----------|------------|------------|
| **Critical** | Must resolve. Blocks next stage or is fundamentally flawed. | Fix before proceeding. |
| **High** | Should resolve. Significant gap or weakness. | Fix before proceeding. |
| **Low** | Minor. Polish, cosmetic, or implementation detail. | Log only; do not spend cycles fixing. |

**The test:** "If this isn't fixed, will the project fail or be significantly worse?" If no, it's Low.

---

## Complexity Assessment

After assigning severity to Critical/High issues, assess **effort required to fix**.

| Complexity | Definition | Examples |
|-----------|------------|----------|
| **Low** | Direct edit, no research, clear fix | Change ID, add missing field, fix typo |
| **Medium** | Requires design thinking, small refactor | Redesign logic, add columns, restructure section |
| **High** | Needs research, investigation, rethinking | Evaluate alternatives, spike unknown APIs, resolve conflicts |

**Purpose:** Complexity drives **action-taking**. Low/Medium fixes are automatic; High complexity flags to user.

---

## Action-Taking Matrix

| Severity | Complexity | Action |
|----------|-----------|--------|
| **Critical/High** | Low | Fix automatically — direct edit |
| **Critical/High** | Medium | Fix automatically — apply design thinking |
| **Critical/High** | High | **Flag for user** — needs research/investigation |
| **Low** | Any | Log only — do not fix |

### Auto-Fix Guidelines

When fixing automatically:
- Apply minimal fix that resolves the issue
- Update related sections for consistency
- Do not expand scope beyond the identified issue
- Log resolution in artifact's issue log

### User Flag Guidelines

When flagging Critical/High + High complexity:
- Clearly state the issue and why it blocks
- Identify what investigation is needed
- Propose 2-3 potential approaches if possible
- Wait for user decision before proceeding

---

## YAGNI Enforcement

Every review — internal and external — applies YAGNI rigorously:

- Only flag issues that **block or significantly harm** the next stage
- Do NOT suggest features, additions, or "nice to haves"
- Do NOT ask "what about X?" unless X is critical to stated goals
- If something is explicitly out of scope, respect it
- Do NOT backdoor scope expansion as "questions to consider"

**Reviewers are validators, not consultants.** Find problems, not opportunities.

---

## Issue Logging

All issues logged in artifact's Issue Log section:

| # | Issue | Source | Severity | Complexity | Status | Resolution |
|---|-------|--------|----------|------------|--------|------------|
| N | [description] | Internal/External-{Model} | Critical/High/Low | Low/Medium/High/N/A | Open/Resolved | [resolution] |

**Complexity column:** Low/Medium/High for Critical/High issues; N/A for Low severity (not fixing).

**Source values:** `Internal`, `External-GPT4`, `External-Gemini`, `Human`.

---

## Cycle Stop Conditions

Review phase is complete when:

1. **Minimum cycles met** (2 for internal, 1 per reviewer for external) AND
2. **No Critical/High issues found** in last cycle

OR

1. **Hard maximum reached** (10 cycles)
2. **Same issue 3+ iterations** — stop and flag to user
3. **Past 4 cycles with Critical issues** — stop and flag (structural problem signal)

---

## Relationship to Other Specs

- **ADF-STAGES-SPEC.md:** Defines stages; this spec defines review mechanism within stages
- **Stage-specific prompts:** Contain review dimensions; this spec provides the mechanism framework

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-30 | Initial spec — two-phase model, severity, cycle rules |
| 1.2.0 | 2026-01-31 | Added complexity assessment, action-taking matrix, Review Log |
| 2.0.0 | 2026-03-23 | Rewrite: removed Ralph Loop references, killed Review Log section, removed frontmatter tracking, streamlined to 150 lines, embedded internal review as mandatory behavior |
