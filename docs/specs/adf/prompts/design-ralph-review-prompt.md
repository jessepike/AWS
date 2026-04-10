---
type: "prompt"
description: "Ralph Loop prompt for Phase 1 internal review in Design stage"
version: "3.0.0"
updated: "2026-01-30"
scope: "design"
mechanism_ref: "~/code/_shared/adf/ADF-REVIEW-SPEC.md"
usage: "Use with Ralph Loop plugin for automated design.md iteration"
---

# Design Internal Review (Phase 1: Ralph Loop)

## Usage

```bash
/ralph-loop:ralph-loop "$(cat ~/code/_shared/adf/prompts/design-ralph-review-prompt.md)" --max-iterations 10 --completion-promise "DESIGN_INTERNAL_REVIEW_COMPLETE"
```

Run from the project root directory. The agent reads project files relative to `$PWD`.

---

## Prompt

```
You are conducting Phase 1 (Internal) review of design.md as part of ADF's Design stage.

## Mechanism

This review follows ADF-REVIEW-SPEC.md. Key rules:
- Minimum 2 review cycles, maximum 10
- Stop when a cycle produces zero Critical and zero High issues
- If past 4 cycles with Critical issues still appearing, stop and flag for human input
- If stuck on same issue for 3+ iterations, stop and flag for human input
- Severity: Critical (blocks next stage), High (significant gap), Low (minor — don't spend cycles)
- YAGNI: only flag issues that block Develop. No feature suggestions, no scope expansion, no over-engineering.
- The test: "If this issue isn't fixed, will Develop fail or produce something significantly wrong?" If no, it's not Critical or High.

## Context

This is Phase 1 of the two-phase review process:
- Phase 1 (you): Thorough internal review — get design.md as strong as possible
- Phase 2 (external): User-driven — fresh perspectives to catch what you missed

## Files

- Design: docs/design.md (in project root)
- Brief: docs/discover-brief.md (in project root)
- Intent: docs/intent.md (in project root)

## Your Task

1. Read design.md, discover-brief.md, and intent.md
2. Review critically — validate decisions, challenge gaps
3. Log issues in design.md Issue Log section
4. Address all Critical and High issues by updating design.md
5. Re-review after changes
6. Repeat until stop conditions are met

## Review Dimensions

**Brief Alignment**
- Does design deliver everything Brief specifies?
- All success criteria addressable?
- Anything contradict the Brief?
- Scope boundaries respected?

**Completeness**
- All required sections for project type present?
- Gaps a developer would stumble on?
- Capabilities inventory sufficient?

**Feasibility**
- Can this be built with stated constraints?
- Technology choices realistic?
- Hidden complexity not accounted for?

**Consistency**
- All sections align with each other?
- Internal contradictions?
- Data model support interface design?

**Interface Clarity**
- Would a developer know what to build?
- Interactions specified, not just screens?
- Edge cases addressed?

**Architecture Soundness**
- Component breakdown logical?
- Boundaries clear?
- Tech stack appropriate?

**Capability Coverage**
- All needed tools/skills/agents identified?
- Gaps in inventory?

**Decision Quality**
- Key decisions documented with rationale?
- Alternatives considered?

**Downstream Usability**
- Could Develop start from this?
- What questions would an implementer have?

## Issue Logging

Log issues in design.md Issue Log:

| # | Issue | Source | Severity | Status | Resolution |
|---|-------|--------|----------|--------|------------|
| N | [description] | Ralph-Design | Critical/High/Low | Open | - |

## Exit Criteria

- [ ] Minimum 2 review cycles completed
- [ ] Last cycle produced zero Critical and zero High issues
- [ ] Design delivers what Brief requires
- [ ] No obvious gaps for implementers

## Completion

When stop conditions are met:

1. Update design.md frontmatter status to "internal-review-complete"
2. Add phase completion entry to Issue Log with cycle count
3. Output: <promise>DESIGN_INTERNAL_REVIEW_COMPLETE</promise>

## Important

Your job is to make design.md **ready for Develop**, not perfect. Design is ready when:
- Architecture is sound for the requirements
- A developer would know what to build
- Technology choices are appropriate
- Capabilities are identified
- No major gaps or contradictions
```
