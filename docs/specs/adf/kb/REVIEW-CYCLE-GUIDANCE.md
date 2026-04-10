---
type: "knowledge-base"
description: "Review cycle stop rules — severity-based scoring with diminishing returns detection"
version: "2.0.0"
created: "2026-01-28"
updated: "2026-01-29"
scope: "adf"
lifecycle: "reference"
tags: ["review", "discover", "design", "develop", "validation"]
---

# Review Cycle Guidance

## Summary

**Stop reviewing when a cycle produces zero Critical and zero High severity issues.** Minimum 2 cycles, maximum 10. This applies to both internal (Ralph Loop) and external review across all stages.

---

## Scoring Mechanism

### Severity Levels

Each issue is tagged with one severity:

| Severity | Definition | Action |
|----------|------------|--------|
| **Critical** | Blocks the next stage or is fundamentally flawed | Must resolve |
| **High** | Significant gap or weakness | Should resolve |
| **Low** | Minor polish, cosmetic, or implementation detail | Can defer or ignore |

Three levels. No numeric scoring. No weighted formulas.

### Stop Rules

- **Minimum:** Always complete at least 2 review cycles
- **Stop when:** A cycle produces zero Critical and zero High issues
- **Hard maximum:** 10 cycles (safety valve — should never hit this)
- **Structural problem signal:** If past 4 cycles and still finding Critical issues, something is fundamentally wrong — stop and flag for human input

### Per-Cycle Check

After each cycle, ask: "Did this cycle surface any Critical or High issues?"
- **Yes** → Continue
- **No** → You're done

---

## Validated Finding

Tested on portfolio website project (App + personal + mvp + standalone):

| Stage | Internal (Ralph Loop) | External | Total |
|-------|----------------------|----------|-------|
| Discover | 2 cycles | 1-2 cycles | 3-4 |
| Design | 2 cycles | 2 cycles | 4 |

**Results from Design stage:**
- 13 issues logged
- 11 resolved
- 1 rejected (scope creep)
- 1 Low left open (acceptable)
- 6 questions captured for Develop
- 11 decisions documented

By round 2 of external review, feedback was solidly Low severity — implementation details that resolve naturally during build.

---

## Cycle Expectations by Complexity

| Project Type | Internal Cycles | External Cycles | Notes |
|--------------|-----------------|-----------------|-------|
| Simple (personal MVP) | 2 | 2 | Stop early, don't over-review |
| Medium (shared, community) | 2-3 | 2 | Standard approach |
| Complex (commercial, multi-component) | 3-4 | 2-3 | More scrutiny justified |

---

## External Review Cross-Referencing

When multiple external reviewers participate:
- If multiple reviewers flag the same issue → likely Critical or High
- If only one reviewer flags it and it's not clearly blocking → probably Low
- Filter aggressively — ignore scope expansion suggestions

---

## Application

This scoring mechanism is incorporated into all review prompts:
- `prompts/ralph-review-prompt.md` (Discover internal)
- `prompts/external-review-prompt.md` (Discover external)
- `prompts/design-ralph-review-prompt.md` (Design internal)
- `prompts/design-external-review-prompt.md` (Design external)
- `prompts/develop-ralph-review-prompt.md` (Develop internal)
- `prompts/develop-external-review-prompt.md` (Develop external)

---

## Source

- Original: Validated through portfolio website project, January 2026
- Updated: Formalized scoring mechanism based on develop stage debrief, January 2026
