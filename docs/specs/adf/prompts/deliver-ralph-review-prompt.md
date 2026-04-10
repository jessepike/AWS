---
type: "prompt"
description: "Ralph Loop prompt for Phase 1 internal review in Deliver stage"
version: "1.0.0"
updated: "2026-02-02"
scope: "deliver"
mechanism_ref: "~/code/_shared/adf/ADF-REVIEW-SPEC.md"
usage: "Use with Ralph Loop plugin for automated deployment plan review"
---

# Deliver Internal Review (Phase 1: Ralph Loop)

## Usage

```bash
/ralph-loop:ralph-loop "$(cat ~/code/_shared/adf/prompts/deliver-ralph-review-prompt.md)" --max-iterations 10 --completion-promise "DELIVER_INTERNAL_REVIEW_COMPLETE"
```

Run from the project root directory. The agent reads project files relative to `$PWD`.

---

## Prompt

```
You are conducting Phase 1 (Internal) review of the deployment plan as part of ADF's Deliver stage.

## Mechanism

This review follows ADF-REVIEW-SPEC.md. Key rules:
- Minimum 2 review cycles, maximum 10
- Stop when a cycle produces zero Critical and zero High issues
- If past 4 cycles with Critical issues still appearing, stop and flag for human input
- If stuck on same issue for 3+ iterations, stop and flag for human input
- Severity: Critical (blocks deployment), High (significant gap), Low (minor — don't spend cycles)
- YAGNI: only flag issues that block deployment. No feature suggestions, no over-engineering, no unnecessary capabilities.
- The test: "If this issue isn't fixed, will deployment fail or produce something unusable?" If no, it's not Critical or High.

## Context

This is Phase 1 of the two-phase review process:
- Phase 1 (you): Thorough internal review of deployment plan and capabilities
- Phase 2 (external): User-driven — fresh perspectives to catch blind spots

## Files

- Plan: docs/adf/plan.md
- Tasks: docs/tasks.md (cross-stage per ADF-TASKS-SPEC.md)
- Manifest: docs/adf/manifest.md
- Capabilities: docs/adf/capabilities.md
- Design: docs/design.md (cross-stage, stays in docs/)
- Deliverable: [varies by project type]

## Your Task

1. Read all Deliver artifacts: manifest.md, capabilities.md, plan.md, tasks.md
2. Review against the deliverable and design requirements
3. Log issues in plan.md Issue Log section
4. Address all Critical and High issues
5. Re-review after changes
6. Repeat until stop conditions are met

## Review Dimensions

**Deployment Target Clarity**
- Is the deployment target clearly specified?
- Is it appropriate for the project type (Artifact, App, Workflow)?
- Are access requirements defined?
- Is the target environment viable?

**Manifest Completeness**
- Are all deployment dependencies identified?
  - Hosting/infrastructure (Railway, Vercel, etc.)
  - Domain/DNS requirements
  - Environment variables/secrets
  - CI/CD pipelines
  - External services (databases, caches)
- Any missing dependencies for deployment?
- Are credentials/access requirements clear?

**Capabilities Coverage**
- Are all needed deployment skills identified?
- Are required testing tools listed?
  - Browser testing tools (browser automation tool (runtime-specific, e.g., Claude in Chrome) for Apps)
  - E2E testing tools (Playwright, Cypress)
  - Validation tools (health checks, curl)
- Are CLIs and tools specified?
- Registry consulted? (Registry Summary section present?)

**Plan Quality**
- Are deployment phases logical and well-sequenced?
- Is the testing strategy adequate? (3-tier coverage)
  - Tier 1: Automated tests in production/target environment
  - Tier 2: Browser/agent testing (browser automation tool (runtime-specific, e.g., Claude in Chrome), MCP Inspector)
  - Tier 3: Manual user validation
- Is the rollback plan viable?
- Is user access clearly defined?
- Are risk areas identified with mitigation?

**Task Atomicity**
- Is each task small enough for single-agent execution?
- Are acceptance criteria clear and testable?
- Are dependencies between tasks noted?
- Can an agent read-complete-verify each task?

**Feasibility**
- Can this deployment plan actually be executed?
- Are there hidden complexities not addressed?
- Does the infrastructure setup make sense?
- Are credentials/access paths clear?

**Testing Strategy (Three-Tier Model)**
- Is Tier 1 (automated) testing comprehensive?
  - API endpoints covered?
  - Integration tests specified?
  - E2E tests planned?
- Is Tier 2 (browser/agent) testing appropriate?
  - Full user flows planned for Apps?
  - MCP Inspector testing for MCP-based Workflows?
- Is Tier 3 (manual) testing defined?
  - User acceptance scenarios specified?
  - Who performs manual testing?
  - Success criteria clear?
- Are tiers correctly scoped for project type?

**Project-Type Appropriateness**
- Does the plan match the project type?
  - **Artifact:** Simple export/distribution (minimal infrastructure)
  - **App (feature):** Deploy to existing production (minimal setup)
  - **App (MVP):** Full infrastructure setup (extensive deployment)
  - **Workflow:** Installation/activation (environment-specific)
- Is the complexity appropriate for the scope?
- Are unnecessary steps identified and removed?

**Build-to-Design Verification**
- Does the deployment plan cover all design requirements?
- Are validation steps sufficient to confirm design alignment?
- Is there a mechanism to verify the deployed artifact matches the design?

**Access and Distribution**
- Is user access clearly defined?
- Are distribution channels appropriate?
- Is access documentation planned?
- Are credentials/permissions handled securely?

## Issue Logging

After each cycle, log issues in plan.md using this format:

```markdown
## Issue Log

### Cycle N

| ID | Severity | Issue | Resolution |
|----|----------|-------|------------|
| N.1 | Critical | [description] | [how fixed or status] |
| N.2 | High | [description] | [how fixed or status] |
```

## Completion

When you reach a cycle with zero Critical and zero High issues:
- State: "DELIVER_INTERNAL_REVIEW_COMPLETE"
- Summarize: total cycles, issues resolved, final state
- Recommend proceeding to external review (Phase 2) or human approval

If you get stuck (>4 cycles with Critical issues, or stuck on same issue 3+ iterations):
- State: "REVIEW_BLOCKED"
- Explain the blocker
- Recommend human input

## YAGNI Enforcement

Only flag issues that BLOCK deployment or create UNUSABLE deployments.

Do NOT flag:
- Nice-to-have features not in design
- Over-engineering opportunities
- Additional capabilities beyond deployment needs
- Style/formatting preferences
- Documentation improvements beyond user access
- Infrastructure optimizations not required for MVP

The deployment plan should be sufficient, not perfect.
```
