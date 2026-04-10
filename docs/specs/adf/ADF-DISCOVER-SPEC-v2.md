---
type: "specification"
description: "Detailed specification for the Discover stage workflow"
version: "2.0.0"
updated: "2026-03-23"
supersedes: "ADF-DISCOVER-SPEC.md (v1.3.0)"
scope: "adf"
lifecycle: "active"
location: "docs/active/ADF-DISCOVER-SPEC-v2.md"
---

# ADF Discover Stage Specification

## Purpose

Define the Discover stage — the first stage in the ADF workflow where raw ideas become a clear, validated Brief ready for Design.

---

## Stage Overview

> **"What are we trying to accomplish?"**

Discover transforms a rough concept into a structured, reviewed Brief. The primary agent works with the human to explore, crystallize, review, and finalize the project definition.

**Deliverables:**
- `intent.md` — North Star (stable, universal)
- `brief.md` — Detailed contract (evolves through review)

---

## Phase Model

| Phase | Description | Human Involvement | Agent Involvement |
|-------|-------------|-------------------|-------------------|
| **Exploration** | Divergent brainstorming — gathering ideas, researching, following threads | High | Low (conversational support) |
| **Crystallization** | Synthesis into coherent draft Brief and Intent | Low-Medium | High (structuring, drafting) |
| **Review Loop** | Structured feedback cycles with external reviewer models | Medium (orchestrating, deciding) | High (processing, integrating) |
| **Finalization** | Exit criteria check, constraints pass, handoff prep | Medium (sign-off) | High (validation checks) |

---

## Inputs

What enters the Discover stage:

| Input | Source | Description |
|-------|--------|-------------|
| Raw idea | Human | Initial concept — may be vague, incomplete, or ambitious |
| Project type guess | Human | Initial classification (Artifact, App, Workflow) |
| Domain context | Human/Research | Relevant background, constraints, prior art |
| ADF specs | Environment layer | Brief spec, Intent spec, Project Types spec |

---

## Outputs

What Discover produces:

| Output | Description | Location |
|--------|-------------|----------|
| `intent.md` | Stable North Star — problem, outcome, why it matters | `/docs/intent.md` |
| `brief.md` | Detailed contract with all required sections | `/docs/brief.md` |

Both artifacts must pass exit criteria before handoff to Design.

---

## Phase Details

### 1. Exploration

**Purpose:** Gather the puzzle pieces. Understand the problem space.

**Activities:**
- Brainstorm with models (conversational, broad)
- Research prior art, competitors, adjacent solutions
- Capture rough notes, questions, possibilities
- Identify constraints and dependencies

**Agent role:** Conversational partner. Ask clarifying questions. Surface considerations. Don't structure yet — let ideas flow.

**Human role:** Provide direction, domain knowledge, gut instincts. Follow interesting threads.

**Exit signal:** Enough raw material to start structuring. Human says "I think I have enough to crystallize."

---

### 2. Crystallization

**Purpose:** Synthesize exploration into structured artifacts.

**Activities:**
- Draft `intent.md` — distill to problem, outcome, why it matters
- Draft `brief.md` — structure per Brief spec
- Assign project classification (type + modifiers)
- Identify initial scope boundaries
- Capture open questions

**Agent role:** Heavy lifting. Take raw inputs and structure them. Propose draft language. Identify gaps.

**Human role:** Review, adjust, approve direction. Fill in domain-specific details.

**Exit signal:** Draft Brief exists with all core sections populated (may be rough). Ready for external review.

---

### 3. Review Loop

**Purpose:** Stress-test the Brief through thorough review.

**Review scope:** Comprehensive. The internal reviewer should challenge everything:

- **Completeness** — All required sections populated? Gaps?
- **Clarity** — Would someone new understand this? Ambiguous language?
- **Measurability** — Success criteria verifiable? Subjective wording?
- **Scope** — Boundaries explicit? In/out clear?
- **Consistency** — Internal contradictions? Conflicts between sections?
- **Intent alignment** — Brief outcomes match Intent goals?
- **Constraint adherence** — Technical decisions honor stated constraints?
- **Downstream usability** — Would Design/Develop know what to do?
- **Assumption risk** — Unstated assumptions? Risky dependencies?
- **Feasibility** — Red flags? Unrealistic expectations?

**Review mechanism:** Review follows ADF-REVIEW-SPEC. Internal review is mandatory. External review is risk-driven, user-triggered.

**Convergence signals:**
- Issue count decreasing across cycles
- Cross-reviewer consensus on core elements
- Diminishing returns on new feedback
- No Critical/High issues remaining
- External reviewers validate rather than challenge

---

### 4. Finalization

**Purpose:** Verify exit criteria. Prepare for Design handoff.

**Activities:**
- Run exit criteria checklist
- Ensure all critical issues resolved
- Confirm open questions are resolved or explicitly deferred
- Add/verify constraints section (resources, timeline, dependencies)
- Update Session State to phase: complete
- Human sign-off

**Agent role:** Run validation checks. Flag any gaps. Prepare handoff summary if needed.

**Human role:** Final review and approval.

**Exit signal:** All exit criteria met. Human confirms ready for Design.

---

## Exit Criteria

### Universal Criteria

Per ADF-STAGES-SPEC.md:

- [ ] Primary deliverable(s) exist with required content
- [ ] No Critical or High issues open (post-review)
- [ ] Alignment verified with intent.md and brief.md
- [ ] All work committed (atomic commits, no uncommitted changes)
- [ ] Documentation appropriate to deliverable exists
- [ ] Workspace cleanup complete (no transients, .gitignore current)
- [ ] status.md updated with stage completion (THE SEAL — last step)
- [ ] Human sign-off obtained

### Discover-Specific Criteria

- [ ] `intent.md` exists and passes Intent spec validation
- [ ] `brief.md` exists with all required sections (core + type-specific)
- [ ] Project classification assigned (type + modifiers)
- [ ] Scope boundaries clear (in/out explicit)
- [ ] Success criteria are verifiable (not vague)
- [ ] Open Questions empty or deferred to Design with rationale
- [ ] Constraints documented

### Stage Boundary Handoff

Per ADF-STAGES-SPEC.md Stage Boundary Handoff Protocol:

1. Complete all exit criteria above
2. Update status.md with structured handoff:
   - **What was produced** — intent.md + brief.md summary
   - **Success criteria status** — from brief.md
   - **Known limitations / deferred items**
   - **Read order for next stage agent**
3. Commit with `chore(discover): stage complete — {summary}`
4. Run `/clear`

---

## Context Loading

### What the Primary Agent Needs

The agent working through Discover needs context on:

1. **ADF Framework** — What is ADF, what stage are we in, how does it work
2. **Stage Workflow** — This spec (phases, activities, exit criteria)
3. **Artifact Specs** — Brief spec, Intent spec
4. **Project Types** — Classification system
5. **Current State** — Where we left off (from Session State in Brief)

### Context Map (for CLAUDE.md)

```markdown
## Context Map

| File | Load When | Purpose |
|------|-----------|---------|
| intent.md | Always | North Star |
| brief.md | Discover stage | Working Brief |
| ADF-DISCOVER-SPEC-v2.md | Discover stage (reference) | Stage workflow |
| ADF-BRIEF-SPEC.md | Discover stage (reference) | Brief structure |
| ADF-INTENT-SPEC.md | Discover stage (reference) | Intent structure |
| ADF-PROJECT-TYPES-SPEC.md | Discover stage (reference) | Classification |
```

Specs are reference documents — load on demand, not into every context.

---

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        DISCOVER STAGE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐                                               │
│  │  EXPLORATION │  Human: High | Agent: Low                     │
│  │  - Brainstorm│                                               │
│  │  - Research  │                                               │
│  │  - Gather    │                                               │
│  └──────┬───────┘                                               │
│         │ "Enough to crystallize"                               │
│         ▼                                                       │
│  ┌──────────────────┐                                           │
│  │  CRYSTALLIZATION │  Human: Low-Med | Agent: High             │
│  │  - Draft Intent  │                                           │
│  │  - Draft Brief   │                                           │
│  │  - Classify      │                                           │
│  └──────┬───────────┘                                           │
│         │ Draft ready                                           │
│         ▼                                                       │
│  ┌────────────────────────────────────────────────────────┐     │
│  │                    REVIEW LOOP                          │     │
│  │                                                        │     │
│  │  Internal review: mandatory                            │     │
│  │  External review: risk-driven, user-triggered         │     │
│  │                                                        │     │
│  │  Iterate until no Critical/High issues remain         │     │
│  └────────────────────────────────────────────────────────┘     │
│         │ Convergence reached                                   │
│         ▼                                                       │
│  ┌──────────────────┐                                           │
│  │   FINALIZATION   │  Human: Med | Agent: High                 │
│  │  - Exit criteria │                                           │
│  │  - Constraints   │                                           │
│  │  - Sign-off      │                                           │
│  └──────┬───────────┘                                           │
│         │                                                       │
│         ▼                                                       │
│  ┌──────────────────────────────────────┐                       │
│  │  OUTPUTS: intent.md, brief.md │                      │
│  └──────────────────────────────────────┘                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                        DESIGN STAGE
```

---

## Session Continuity

Discover may span multiple sessions. To maintain continuity:

1. **Session State** in Brief tracks current phase, last action, next steps
2. **Issue Log** in Brief tracks all feedback and resolution status
3. **Revision History** in Brief tracks document evolution

New session workflow:
1. Agent reads CLAUDE.md (loads context map)
2. Agent reads `brief.md` (gets Session State)
3. Agent picks up where previous session left off
4. At session end, agent updates Session State

---

## Planning Artifacts Convention

When Discover produces working artifacts beyond intent.md and brief.md (e.g., research notes, exploration logs), place them in `docs/active/` per ADF-FOLDER-STRUCTURE-SPEC.md. These are stage-scoped and archived at stage completion.

---

## References

- ADF-STAGES-SPEC.md (Universal exit criteria, stage boundary handoff)
- ADF-BRIEF-SPEC.md (Brief structure and requirements)
- ADF-INTENT-SPEC.md (Intent structure and requirements)
- ADF-PROJECT-TYPES-SPEC.md (Classification system)
- ADF-FOLDER-STRUCTURE-SPEC.md (docs/active/ convention)
- ADF-TAXONOMY.md (Terminology definitions)
- ADF-REVIEW-SPEC.md (Review mechanism)
