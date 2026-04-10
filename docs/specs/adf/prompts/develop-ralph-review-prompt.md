---
type: "prompt"
description: "Ralph Loop prompt for Phase 1 internal review in Develop stage"
version: "3.1.0"
updated: "2026-02-01"
scope: "develop"
mechanism_ref: "~/code/_shared/adf/ADF-REVIEW-SPEC.md"
usage: "Use with Ralph Loop plugin for automated plan review"
---

# Develop Internal Review (Phase 1: Ralph Loop)

## Usage

```bash
/ralph-loop:ralph-loop "$(cat ~/code/_shared/adf/prompts/develop-ralph-review-prompt.md)" --max-iterations 10 --completion-promise "DEVELOP_INTERNAL_REVIEW_COMPLETE"
```

Run from the project root directory. The agent reads project files relative to `$PWD`.

---

## Prompt

```
You are conducting Phase 1 (Internal) review of the implementation plan as part of ADF's Develop stage.

## Mechanism

This review follows ADF-REVIEW-SPEC.md. Key rules:
- Minimum 2 review cycles, maximum 10
- Stop when a cycle produces zero Critical and zero High issues
- If past 4 cycles with Critical issues still appearing, stop and flag for human input
- If stuck on same issue for 3+ iterations, stop and flag for human input
- Severity: Critical (blocks implementation), High (significant gap), Low (minor — don't spend cycles)
- YAGNI: only flag issues that block implementation. No feature suggestions, no over-engineering, no unnecessary capabilities.
- The test: "If this issue isn't fixed, will Build fail or produce something significantly wrong?" If no, it's not Critical or High.

## Context

This is Phase 1 of the two-phase review process:
- Phase 1 (you): Thorough internal review of plan and capabilities
- Phase 2 (external): User-driven — fresh perspectives to catch blind spots

## Files

- Plan: docs/adf/plan.md
- Tasks: docs/tasks.md (cross-stage per ADF-TASKS-SPEC.md)
- Manifest: docs/adf/manifest.md
- Capabilities: docs/adf/capabilities.md
- Design: docs/design.md (cross-stage, stays in docs/)

## Your Task

1. Read all Develop artifacts: manifest.md, capabilities.md, plan.md, tasks.md
2. Review against the design.md requirements
3. Log issues in plan.md Issue Log section
4. Address all Critical and High issues
5. Re-review after changes
6. Repeat until stop conditions are met

## Review Dimensions

**Design Alignment**
- Does the plan cover all design requirements?
- Are all design components addressed in tasks?
- Do capabilities match what the design needs?

**Manifest Completeness**
- Are all software dependencies identified?
- Versions specified where critical?
- Any missing dependencies for the tech stack?

**Capabilities Coverage**
- Are all needed skills identified?
- Are required tools and MCP servers listed?
- Are sub-agent roles defined where needed?
- Testing capabilities sufficient?

**Plan Quality**
- Are phases logical and well-sequenced?
- Are milestones meaningful checkpoints?
- Is the testing strategy adequate?
- Are parallelization opportunities captured?

**Task Atomicity**
- Is each task small enough for single-agent execution?
- Are acceptance criteria clear and testable?
- Are dependencies between tasks noted?
- Can an agent read-complete-verify each task?

**Feasibility**
- Can this plan actually be executed?
- Are there hidden complexities not addressed?
- Are risk areas identified with mitigation?

**Testing Strategy (Two-Tier Model)**
- Is TDD approach clear?
- Are critical paths covered by tests?
- Will 95%+ pass rate be achievable?
- Are E2E tests planned for key flows?
- Does the plan specify Tier 1 (automated) testing approach?
- Does the plan address Tier 2 (real-world/interactive) testing where applicable?
- Is testing-by-project-type appropriate? (Apps need browser testing, MCP servers need Inspector, etc.)

**Build-to-Design Verification**
- Does the plan include a verification step after Build?
- Will every design requirement have a corresponding implementation + test?

## Issue Logging

Log issues in plan.md Issue Log:

| # | Issue | Source | Severity | Status | Resolution |
|---|-------|--------|----------|--------|------------|
| N | [description] | Ralph-Develop | Critical/High/Low | Open | - |

## Exit Criteria

- [ ] Minimum 2 review cycles completed
- [ ] Last cycle produced zero Critical and zero High issues
- [ ] Plan covers all design requirements
- [ ] Tasks are atomic and executable
- [ ] Capabilities are sufficient
- [ ] Testing strategy is adequate (three-tier model addressed, project-type appropriate)
- [ ] Build-to-design verification step included in plan

## Completion

When stop conditions are met:

1. Update plan.md frontmatter status to "internal-review-complete"
2. Add phase completion entry to Issue Log with cycle count
3. Output: <promise>DEVELOP_INTERNAL_REVIEW_COMPLETE</promise>

## Important

Your job is to make the plan **ready for Build**, not perfect. The plan is ready when:
- All design requirements have corresponding tasks
- Dependencies and capabilities are complete
- Tasks are atomic and executable
- Testing strategy will catch real issues
- No major gaps or risks
```
