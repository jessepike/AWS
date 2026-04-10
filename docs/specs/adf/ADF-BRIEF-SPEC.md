---
type: "specification"
description: "Defines brief.md — the detailed project contract produced in Discover"
version: "2.1.0"
updated: "2026-01-27"
scope: "adf"
lifecycle: "reference"
location: "adf/ADF-BRIEF-SPEC.md"
---

# ADF Brief Specification

## Purpose

Define `brief.md` — the detailed contract that captures what we're building, why, scope boundaries, success criteria, and constraints. The Brief is the primary deliverable of the Discover stage.

---

## Relationship to Intent

| Artifact | Role | Size | Context Loading |
|----------|------|------|-----------------|
| `intent.md` | North Star — why we're doing this | ~50-150 words | Every agent, every stage |
| `brief.md` | Detailed contract — what, scope, success criteria | ~300-800 words | Consumed in Design, referenced in Develop/Deliver |

**Intent is stable and universal. Brief is detailed and stage-specific.**

The Brief references Intent but does not duplicate it. Intent travels everywhere; Brief is pulled when needed.

---

## Brief Lifecycle

| Stage | Brief Role | Action |
|-------|------------|--------|
| **Discover** | Primary working document | Created, iterated, refined through review loops |
| **Design** | Input | Consumed to drive architecture and technical decisions |
| **Develop** | Reference | Referenced to validate "are we building what we said?" |
| **Deliver** | Verification | Referenced to confirm success criteria met |

**Key principle:** Brief is written once (in Discover), consumed once (in Design), and referenced thereafter. It flows downstream but isn't loaded into every context.

---

## Brief Evolution (Discover Phase)

The Brief starts rough and refines through iteration:

```
Raw idea → Draft v0.1 → Review Cycle 1 → v0.2 → Review Cycle 2 → ... → Complete
```

### Status Progression

| Status | Meaning |
|--------|---------|
| `draft` | Initial capture — rough, incomplete, exploratory |
| `in-review` | Undergoing review loop with external reviewers |
| `complete` | Exit criteria met, ready for Design handoff |

### Iteration Tracking

Use simple review cycle numbering in frontmatter:

```yaml
status: "in-review"
review_cycle: 3
last_reviewed: "2026-01-27"
```

---

## Content Structure

### Core Sections (Required for All Types)

Every Brief contains these seven elements:

#### 1. Project Classification

Type and modifiers from ADF-PROJECT-TYPES-SPEC.

```markdown
## Classification

- **Type:** App
- **Scale:** personal
- **Scope:** mvp
- **Complexity:** standalone
```

#### 2. Summary

One paragraph stating what we're building and why. References `intent.md`.

#### 3. Scope

What's included and explicitly excluded.

| In Scope | Out of Scope |
|----------|--------------|
| [What we will do] | [What we won't do — and why] |

#### 4. Success Criteria

How we'll know it's done. Measurable where possible.

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

#### 5. Constraints

Known limitations: time, resources, dependencies, technical boundaries, MVP trade-offs.

#### 6. Open Questions

Unknowns to resolve. Captured so they're not forgotten. Should be empty or minimal by Brief completion.

#### 7. Issue Log

Running tracker of feedback from review loops.

| # | Issue | Source | Impact | Priority | Status | Resolution |
|---|-------|--------|--------|----------|--------|------------|
| 1 | Target audience unclear | Claude-Sonnet | High | P1 | Resolved | Added persona section |
| 2 | MVP scope too broad | GPT-4 | High | P1 | Resolved | Narrowed to core features |
| 3 | Success criteria vague | Claude-Sonnet | Med | P2 | Open | Needs quantification |

**Source:** Identifies which reviewer/model raised the issue (enables consensus tracking).

**Priority:**
- P1: Must resolve before completion
- P2: Should resolve, may defer to Design
- P3: Nice to have, can defer

**Status:** Open → In Progress → Resolved | Deferred

---

### Optional Supporting Sections

These sections support the discovery process. Include as needed.

#### 8. Backlog / Parking Lot

Ideas captured during exploration that shouldn't be lost but aren't in current scope. Revisit in future iterations or stages.

```markdown
## Backlog

| Idea | Context | Revisit When |
|------|---------|--------------|
| Mobile app version | Came up in review cycle 2 | Post-MVP |
| Integration with X | User mentioned, not core | Design stage |
```

Keep lightweight. If this grows large, graduate to separate `backlog.md` in Design or Develop.

#### 9. Decision Log

Key decisions made during Discover with rationale. Prevents revisiting and documents "why."

```markdown
## Decision Log

| Decision | Options Considered | Chosen | Rationale | Date |
|----------|-------------------|--------|-----------|------|
| Target audience | Broad vs niche | Niche (developers) | Better differentiation, clearer messaging | 2026-01-27 |
| MVP scope | Full features vs core | Core only | Ship fast, validate assumptions | 2026-01-27 |
```

Keep brief. If decisions accumulate significantly in Design/Develop, graduate to separate `decisions.md` or ADR format.

---

### Type-Specific Extensions

Based on project classification, additional sections are required. Progressive disclosure — only include what's relevant.

#### App + Commercial Extensions

Required when `Type: App` and `Scale: commercial`:

| Section | Purpose |
|---------|---------|
| **Target Market** | Who is this for? Primary persona, market segment. |
| **Competitive Landscape** | Key competitors, differentiation, positioning. |
| **Monetization Model** | How will this generate revenue? Pricing approach. |
| **Financial Forecast** | Basic projections: costs, revenue targets, break-even. |
| **Go-to-Market** | High-level launch and distribution strategy. |

#### Workflow Extensions

Required when `Type: Workflow`:

| Section | Purpose |
|---------|---------|
| **Trigger Definition** | What initiates the workflow? Event, schedule, manual. |
| **Integration Points** | External systems, APIs, data sources involved. |
| **Data Flow** | What goes in, what comes out, transformations. |
| **Error Handling** | How failures are detected and managed. |

#### Artifact Extensions

Required when `Type: Artifact`:

| Section | Purpose |
|---------|---------|
| **Target Audience** | Who will consume this? Their context and needs. |
| **Format Requirements** | Deliverable format, length, style constraints. |
| **Source Materials** | Inputs, research, references to incorporate. |

---

## Review Cycle Guidance

Review depth and cycle count scale by project type and complexity.

| Type + Scale | Typical Cycles | Review Focus |
|--------------|----------------|--------------|
| Artifact | 1-3 | Clarity, completeness, audience fit |
| App (personal) | 2-4 | Scope, feasibility, success criteria |
| App (shared/community) | 3-5 | User needs, scope, technical feasibility |
| App (commercial) | 4-8 | Market fit, financials, competitive position, feasibility |
| Workflow | 2-4 | Integration points, edge cases, error handling |

**Review prompt layering:**
- Base review prompt applies to all types
- Type-specific modules add focused review areas (e.g., commercial adds market/financial review)

---

## Session State

Session state is tracked in a separate `status.md` file, not embedded in the Brief. This keeps the Brief focused on the project contract while status.md handles dynamic session continuity.

See: ADF-STATUS-SPEC.md for status.md structure and behavior.

---

## Format Example

```markdown
---
type: "brief"
project: "[Project Name]"
version: "0.1"
status: "draft"
review_cycle: 0
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
intent_ref: "./intent.md"
---

# Brief: [Project Name]

## Classification

- **Type:** [Artifact | App | Workflow]
- **Scale:** [personal | shared | community | commercial]
- **Scope:** [mvp | full-build]
- **Complexity:** [standalone | multi-component]

## Summary

[1 paragraph — what we're building and why. Reference intent.md for the North Star.]

## Scope

### In Scope
- [Item]
- [Item]

### Out of Scope
- [Item — and why excluded]
- [Item — and why excluded]

## Success Criteria

- [ ] [Measurable criterion]
- [ ] [Measurable criterion]
- [ ] [Measurable criterion]

## Constraints

- [Constraint: time, budget, technical, dependencies]
- [Constraint]

## Open Questions

- [Question to resolve — owner if known]
- [Question to resolve]

<!-- Type-specific extensions go here based on classification -->

## Issue Log

| # | Issue | Source | Severity | Complexity | Status | Resolution |
|---|-------|--------|----------|------------|--------|------------|
| - | - | - | - | - | - | - |

## Review Log

### Phase 1: Internal Review

**Date:** YYYY-MM-DD
**Mechanism:** Ralph Loop (N cycles)
**Issues Found:** N Critical, N High, N Low
**Complexity Assessment:** N Low, N Medium, N High
**Actions Taken:**
- **Auto-fixed (N issues):**
  - [Issue] (Severity/Complexity) — [Resolution]
- **Logged only (N issues):**
  - [Issue] (Low/N/A) — [Why deferred]

**Outcome:** [Status and next steps]

### Phase 2: External Review

**Date:** YYYY-MM-DD
**Reviewers:** External-Model1, External-Model2
**Issues Found:** N Critical, N High, N Low
**Complexity Assessment:** N Low, N Medium, N High
**Actions Taken:**
- **Auto-fixed (N issues):**
  - [Issue] (Severity/Complexity) — [Resolution]
- **Flagged for user (N issues):**
  - [Issue] (Severity/High) — [Investigation needed]
- **Logged only (N issues):**
  - [Issue] (Low/N/A) — [Why deferred]

**Cross-Reviewer Consensus:**
- [Issues with consensus and weighting]

**Outcome:** [Status and next steps]

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 0.1 | YYYY-MM-DD | Initial draft |
```

**Note:** This is a format example, not a template. Agents generate the Brief from this spec; they don't copy/paste a scaffold.

---

## Exit Criteria (Discover → Design Handoff)

A Brief is **complete** when:

- [ ] All required sections populated (core + type-specific)
- [ ] Project classification assigned
- [ ] Scope boundaries clear (in/out explicit)
- [ ] Success criteria are verifiable (not vague)
- [ ] No P1 issues open in Issue Log
- [ ] Open Questions empty or deferred to Design with rationale
- [ ] status.md updated with stage completion
- [ ] Human sign-off

**Convergence signal:** Issue count decreasing across review cycles, cross-reviewer consensus on core elements, diminishing returns on feedback.

---

## Review Loop

The Brief is refined through external reviewer feedback:

1. **Submit** Brief + review prompt to reviewer model
2. **Receive** feedback (issues, gaps, suggestions)
3. **Log** issues in Issue Log with source attribution
4. **Prioritize** based on impact and cross-reviewer consensus
5. **Address** P1s, assess P2s
6. **Update** Session State with progress
7. **Iterate** until exit criteria met

**Consensus tracking:** Issues flagged by multiple reviewers get weighted higher. "6 of 8 reviewers flagged X" = high confidence signal.

---

## Scope Changes (Post-Discover)

If Design or later stages reveal scope issues:

1. **Flag** the issue — don't just note deviation
2. **Assess impact** — is this a P1 that invalidates assumptions?
3. **Re-validate** if significant — may require mini review cycle
4. **Update Brief** with change tracking (new version, revision history entry)
5. **Propagate** — ensure downstream artifacts reflect change

Scope drift without explicit acknowledgment = red flag.

---

## What Brief Does NOT Contain

- Implementation details (that's Design)
- Technical architecture (that's Design)
- Code or configuration (that's Develop)
- Deployment specifics (that's Deliver)

Brief answers "what and why." Design answers "how."

---

## File Location

Briefs live in the project's `/docs/` directory with stage prefix:

```
/project-root/
  docs/
    intent.md
    brief.md
  CLAUDE.md
  README.md
```

---

## References

- ADF-INTENT-SPEC.md (Intent is the North Star, Brief references it)
- ADF-PROJECT-TYPES-SPEC.md (Classification system)
- ADF-STAGES-SPEC.md (Discover stage outputs Brief)
- ADF-DISCOVER-SPEC.md (Detailed Discover workflow)
- ADF-GLOSSARY.md (Terminology definitions)
