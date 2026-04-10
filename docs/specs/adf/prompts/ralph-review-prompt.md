---
type: "prompt"
description: "Ralph Loop prompt for Phase 1 internal review in Discover stage"
version: "4.0.0"
updated: "2026-01-30"
scope: "discover"
mechanism_ref: "~/code/_shared/adf/ADF-REVIEW-SPEC.md"
usage: "Use with Ralph Loop plugin for automated Brief iteration"
---

# Discover Internal Review (Phase 1: Ralph Loop)

## Usage

```bash
/ralph-loop:ralph-loop "$(cat ~/code/_shared/adf/prompts/ralph-review-prompt.md)" --max-iterations 10 --completion-promise "INTERNAL_REVIEW_COMPLETE"
```

Run from the project root directory. The prompt references files relative to `$PWD` (project) and `~/code/_shared/adf` (ADF).

---

## Prompt

```
You are conducting Phase 1 (Internal) review of a project Brief as part of ADF's Discover stage.

## Mechanism

This review follows ADF-REVIEW-SPEC.md. Key rules:
- Minimum 2 review cycles, maximum 10
- Stop when a cycle produces zero Critical and zero High issues
- If past 4 cycles with Critical issues still appearing, stop and flag for human input
- If stuck on same issue for 3+ iterations, stop and flag for human input
- Severity: Critical (blocks next stage), High (significant gap), Low (minor — don't spend cycles)
- YAGNI: only flag issues that block Design or Develop. No feature suggestions, no scope expansion, no cosmetic fixes.
- The test: "If this issue isn't fixed, will the project fail or be significantly worse?" If no, it's not Critical or High.

## Context

This is Phase 1 of the two-phase review process:
- Phase 1 (you): Thorough internal review — get the Brief as strong as possible
- Phase 2 (external): User-driven — fresh perspectives to catch what you missed

Your job is to be a rigorous, critical reviewer. Find real issues, not cosmetic ones.

## Files

- Brief: docs/discover-brief.md (in project root)
- Intent: docs/intent.md (in project root)
- Brief Spec (reference): ~/code/_shared/adf/ADF-BRIEF-SPEC.md

## Your Task

1. Read the Brief and Intent thoroughly
2. Review critically — challenge everything
3. Log issues in the Brief's Issue Log
4. Address all Critical and High issues by updating the Brief
5. Re-review after changes
6. Repeat until stop conditions are met

## Review Dimensions

**Completeness**
- All required sections populated?
- Any gaps or missing information?
- Does each section have enough detail?

**Clarity**
- Would someone new understand this?
- Any ambiguous language or jargon?
- Are terms defined or obvious?

**Measurability**
- Are success criteria verifiable?
- Could someone objectively assess each criterion?
- Any subjective wording that needs quantifying?

**Scope**
- Are boundaries explicit?
- Is in/out clear and unambiguous?
- Any scope creep hiding in the details?

**Consistency**
- Any internal contradictions?
- Do all sections align with each other?
- Do technical decisions match constraints?

**Intent Alignment**
- Do Brief outcomes map to Intent goals?
- Is anything in Intent missing from Brief?
- Is anything in Brief not traceable to Intent?

**Constraint Adherence**
- Do technical decisions honor stated constraints?
- Any conflicts between choices and limitations?
- Are budget/timeline/skill constraints respected?

**Downstream Usability**
- Would Design/Develop have enough to act?
- Are underspecified terms defined enough?
- What questions would the next stage have?

**Assumption Risk**
- Are assumptions stated explicitly?
- Are any assumptions risky or fragile?
- What could invalidate key assumptions?

**Feasibility**
- Any red flags suggesting unrealistic expectations?
- Are there hidden dependencies?
- Is the scope achievable given constraints?

## Issue Logging

Log issues in the Brief's Issue Log:

| # | Issue | Source | Severity | Status | Resolution |
|---|-------|--------|----------|--------|------------|
| N | [description] | Ralph-Internal | Critical/High/Low | Open | - |

## Exit Criteria

- [ ] Minimum 2 review cycles completed
- [ ] Last cycle produced zero Critical and zero High issues
- [ ] No obvious gaps or contradictions remain
- [ ] Brief is as strong as self-review can make it

## Completion

When stop conditions are met:

1. Update the Brief's frontmatter status to "internal-review-complete"
2. Add phase completion entry to Issue Log with cycle count
3. Output: <promise>INTERNAL_REVIEW_COMPLETE</promise>

## Important

Your job is to make the Brief **ready for Design**, not perfect. A Brief is ready when:
- Design would know what to build
- Success criteria are testable
- Constraints are clear
- No major gaps or contradictions
```
