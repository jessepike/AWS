---
type: "specification"
description: "Detailed specification for the Design stage workflow"
version: "2.0.0"
updated: "2026-03-23"
supersedes: "ADF-DESIGN-SPEC.md (v1.2.0)"
scope: "adf"
lifecycle: "active"
location: "docs/active/ADF-DESIGN-SPEC-v2.md"
---

# ADF Design Stage Specification

## Purpose

Define the Design stage — the second stage in the ADF workflow where a validated Brief becomes technical specifications ready for development.

---

## Stage Overview

> **"How will we build this?"**

Design transforms a validated Brief into actionable technical decisions. The agent works with the human to clarify ambiguities, explore approaches, make decisions, and document them in a design specification.

**Primary Deliverable:**
- `design.md` — Technical specification covering architecture, interface, data, and capabilities

**Supporting Deliverables (when complexity requires):**
- `design-architecture.md` — System architecture (Apps, complex Workflows)
- `design-data-model.md` — Data structures and persistence
- `design-interface.md` — UI/UX or format specification
- Individual ADRs for significant decisions

---

## Phase Model

| Phase | Description | Human Involvement | Agent Involvement |
|-------|-------------|-------------------|-------------------|
| **Intake & Clarification** | Understand Brief, resolve ambiguities, surface decisions | High (answering questions, making choices) | High (structured questioning, probing) |
| **Technical Design** | Produce design artifacts based on decisions | Low-Medium (review, feedback) | High (drafting, iterating) |
| **Review Loop** | Validate decisions through internal and external review | Medium (orchestrating external, deciding on feedback) | High (integrating feedback) |
| **Finalization** | Exit criteria check, handoff prep | Medium (sign-off) | High (validation checks) |

---

## Inputs

What enters the Design stage:

| Input | Source | Description |
|-------|--------|-------------|
| `intent.md` | Discover | North Star — loaded for alignment |
| `brief.md` | Discover | Detailed contract — primary input, fully consumed |
| Project classification | Brief | Type + modifiers determine required outputs |
| ADF specs | Environment layer | Design spec, Project Types spec |
| Current state | `status.md` | Where we left off (if resuming) |

---

## Outputs

What Design produces:

| Output | Description | Location |
|--------|-------------|----------|
| `design.md` | Primary technical specification | `/docs/design.md` |
| Supporting specs | Architecture, data model, interface (if >500 lines) | `/docs/design-*.md` |
| Updated decision log | Key decisions with rationale | Section in design.md or `/docs/decisions.md` |
| Updated backlog | Implementation ideas, deferred features | Section in design.md or `/BACKLOG.md` |

All artifacts must pass exit criteria before handoff to Develop.

---

## Breakout Threshold

**500 lines** — the threshold for splitting artifacts.

**Under 500 lines:** Keep everything in `design.md` with sections for architecture, interface, data, capabilities.

**Over 500 lines:** Create parent `design.md` (~100-200 lines) with:
- Overview and purpose
- Links to sub-documents
- Decision log summary

Child documents each stay under 500 lines:
- `design-architecture.md`
- `design-interface.md`
- `design-data-model.md`
- `design-capabilities.md`

**Rationale:** 500 lines (~3,000-3,500 tokens) sits in the reliable zone for LLM processing, avoids "lost in the middle" degradation, and remains human-reviewable in one sitting.

---

## Phase Details

### 1. Intake & Clarification

**Purpose:** Ensure agent fully understands Brief and human has made all necessary decisions before design work begins.

**Activities:**
- Read and internalize Brief + Intent
- Identify ambiguities, gaps, implicit assumptions
- Surface decisions that need human input
- Clarify technical preferences and constraints
- Identify recommended capabilities (tools, skills, sub-agents)

**Agent role:** Active interviewer. Use structured questioning to probe deeply. Challenge assumptions. Surface non-obvious considerations. Recommend approaches where appropriate.

**Human role:** Answer questions, make decisions, provide domain context. This phase is highly interactive.

**Questioning scope:**
- Brief interpretation ("I read X as meaning Y — correct?")
- Ambiguity resolution ("Brief says 'simple auth' — what does that mean specifically?")
- Technical preferences ("Any strong opinions on stack, or should I recommend?")
- Constraint clarification ("You listed 'low cost' — is there a specific ceiling?")
- Proactive recommendations ("Based on Brief, I'd suggest X approach — thoughts?")
- Risk surfacing ("I see potential issue with Y — how do you want to handle?")
- Prioritization ("If we hit constraints, what's negotiable vs non-negotiable?")
- Capabilities ("Based on this, you'll need X, Y, Z tools — anything else you want available?")

**What NOT to ask:**
- Timeline estimates ("this will take X weeks")
- Resource/effort planning (that's Develop's concern)
- Scope expansion suggestions (YAGNI — stick to Brief)

**Exit signal:** Agent has enough clarity to draft design.md. Human confirms: "You have what you need."

---

### 2. Technical Design

**Purpose:** Produce design artifacts that capture all technical decisions needed for development.

**Activities:**
- Draft `design.md` with all required sections
- Document architecture decisions (for Apps/Workflows)
- Specify interface and format requirements
- Define data model (if applicable)
- Inventory required capabilities
- Capture decisions in decision log
- Note deferred items in backlog

**Agent role:** Heavy lifting. Translate clarified requirements into technical specifications. Propose concrete approaches. Identify gaps during drafting.

**Human role:** Review drafts, provide feedback, approve direction.

**Exit signal:** Draft design.md exists with all required sections populated. Ready for review.

---

### 3. Review Loop

**Purpose:** Validate design decisions through structured review.

**Review scope:**

- **Brief alignment** — Does design deliver what Brief specifies?
- **Completeness** — All required sections for project type?
- **Feasibility** — Can this actually be built with stated constraints?
- **Consistency** — Internal contradictions? Conflicting decisions?
- **Capability coverage** — Are identified tools/skills sufficient?
- **Interface clarity** — Would a developer know what to build?
- **Data model soundness** — Structures support the requirements?
- **Decision quality** — Rationale documented? Options considered?
- **Downstream usability** — Can Develop start from this?

**Review mechanism:** Review follows ADF-REVIEW-SPEC. Internal review is mandatory. External review is risk-driven, user-triggered.

---

### 4. Finalization

**Purpose:** Verify exit criteria. Prepare for Develop handoff.

**Activities:**
- Run exit criteria checklist
- Ensure all critical issues resolved
- Verify capabilities inventory is complete (Develop can add more if needed)
- Confirm decision log captures key choices
- Update backlog with any deferred items
- Prepare Develop Handoff section (see below)
- Update status.md to stage: complete
- Human sign-off

**Agent role:** Run validation checks. Flag any gaps. Prepare handoff summary.

**Human role:** Final review and approval.

**Exit signal:** All exit criteria met. Human confirms ready for Develop.

---

## Type-Specific Outputs

Design outputs vary by project type. Use this as guidance, not rigid requirement.

### All Types (Required)

| Section | Purpose |
|---------|---------|
| **Summary** | What this design accomplishes, reference to Brief |
| **Capabilities** | Tools, skills, sub-agents, integrations needed |
| **Interface & Format** | How users/consumers interact with the output |
| **Decision Log** | Key decisions with rationale |
| **Backlog** | Deferred items for future consideration |
| **Open Questions** | Anything unresolved (should be minimal) |
| **Issue Log** | Issues found during review with severity and resolution |
| **Develop Handoff** | Stage transition document — summary, decisions, capabilities, open questions, success criteria, implementation guidance |
| **Review Log** | Chronological record of review phases, findings, and actions taken |
| **Revision History** | Version history with dates and changes |

### App (Additional)

| Section | Purpose |
|---------|---------|
| **Architecture** | System structure, components, relationships |
| **Tech Stack** | Languages, frameworks, services, infrastructure |
| **Data Model** | Entities, relationships, persistence approach |
| **Security** | Auth, authorization, data protection approach |

### Workflow (Additional)

| Section | Purpose |
|---------|---------|
| **Orchestration** | How steps coordinate, sequencing, parallelism |
| **Integration Points** | External systems, APIs, data sources |
| **Data Flow** | Inputs, transformations, outputs |
| **Error Handling** | Failure modes, retry logic, alerting |
| **Triggers** | What initiates the workflow, scheduling |

### Artifact (Additional)

| Section | Purpose |
|---------|---------|
| **Format Specification** | File type, structure, styling requirements |
| **Content Outline** | Sections, flow, key elements |
| **Source Materials** | Inputs, references, data to incorporate |

---

## Develop Handoff Section

**Purpose:** Create a stage transition document that gives Develop everything needed to start implementation without re-reading the entire design.

**Location:** Between Issue Log and Review Log sections in design.md.

**Required subsections:**

### Design Summary
- 2-3 sentence overview of what was designed
- Project type, scope, architecture approach

### Key Design Decisions
- Table format: Decision | Rationale | Implication for Develop
- Include decisions from Decision Log that directly affect implementation
- Focus on "what Develop needs to know" not exhaustive history

### Capabilities Needed
- Runtime, libraries, tools, integrations
- Configuration requirements (.env, config files)
- Any external service dependencies

### Open Questions for Develop
- List all Open Questions marked "Implement during Develop" or "Address during Develop"
- Number them for easy tracking
- Include context for why they're deferred (not just "figure it out")

### Success Criteria (Verify During Implementation)
- Copy relevant success criteria from Brief
- Make them checkboxes so Develop can track
- These are the acceptance tests

### What Was Validated
- Summarize review outcomes
- Note what core design elements were validated
- Give Develop confidence about what's solid

### Implementation Guidance
- Recommended build order
- Edge cases to test
- Integration test strategy
- Project structure reference

### Reference Documents
- Point to Intent, Brief, Design
- Specify read order

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

### Design-Specific Criteria

- [ ] `design.md` exists with all required sections (core + type-specific)
- [ ] Design aligns with Brief — delivers what was specified
- [ ] Capabilities inventory complete (tools, skills, agents identified)
- [ ] Interface/format specified clearly enough for implementation
- [ ] Decision log captures key choices with rationale
- [ ] Open Questions empty or explicitly deferred to Develop
- [ ] **Develop Handoff section complete** — summarizes design, decisions, open questions, success criteria, implementation guidance

### HARD GATE Requirements (Before Develop)

**These requirements must be met before approving Design → Develop transition.**

**Problem Validation:**
- [ ] Problem statement exists and is specific (not generic or assumed)
- [ ] Problem is validated through evidence (measurements, user feedback, observation)
- [ ] Current state is measured and understood (baseline metrics captured)
- [ ] Solution doesn't duplicate existing framework capability

**Design Quality:**
- [ ] All requirements have clear, measurable acceptance criteria
- [ ] All assumptions are either validated OR have validation plans WITH commitments
- [ ] Success criteria are measurable BEFORE implementation starts
- [ ] "How do we know this works?" has a concrete answer (not "we'll find out later")

**Risk Assessment:**
- [ ] Technical feasibility confirmed (not theoretical)
- [ ] Resource estimate provided (time/cost/dependencies)
- [ ] "What if we don't build this?" question answered explicitly
- [ ] Alternative approaches considered and documented

**Decision Forcing:**
- [ ] No success criteria marked "partial" or "deferred to validation later"
- [ ] No assumptions marked "to be validated during implementation"
- [ ] No critical dependencies on unproven technology or unvalidated claims

### Type-Specific Criteria

**For Apps/Workflows (additional):**
- [ ] Architecture documented (or confirmed unnecessary)
- [ ] Tech stack specified
- [ ] Data model defined (if applicable)

### Stage Boundary Handoff

Per ADF-STAGES-SPEC.md Stage Boundary Handoff Protocol:

1. Complete all exit criteria above
2. Update status.md with structured handoff:
   - **What was produced** — design.md summary + key decisions
   - **Success criteria status** — from brief.md
   - **Known limitations / deferred items**
   - **Read order for next stage agent**
3. Commit with `chore(design): stage complete — {summary}`
4. Run `/clear`

---

## Context Loading

### What the Primary Agent Needs

The agent working through Design needs context on:

1. **ADF Framework** — What is ADF, what stage are we in
2. **Stage Workflow** — This spec (phases, activities, exit criteria)
3. **Project Artifacts** — Intent (always), Brief (consumed), existing project state
4. **Project Types** — Classification system (determines required outputs)
5. **Current State** — Where we left off (from status.md)

### Context Map (for CLAUDE.md)

```markdown
## Context Map

| File | Load When | Purpose |
|------|-----------|---------|
| intent.md | Always | North Star |
| brief.md | Design stage | Primary input — fully consumed |
| design.md | Design stage (after created) | Working design spec |
| ADF-DESIGN-SPEC-v2.md | Design stage (reference) | Stage workflow |
| ADF-PROJECT-TYPES-SPEC.md | Design stage (reference) | Output requirements by type |
```

Specs are reference documents — load on demand, not into every context.

---

## Capabilities in Design vs Develop

**Design identifies** recommended capabilities based on architecture decisions:
- "Based on this design, you'll need: Python 3.11+, PostgreSQL, Redis for caching, OpenAI API access, the Excel skill for report generation"

**Develop can modify** during implementation:
- Add capabilities discovered during build
- Remove capabilities that aren't needed
- Substitute alternatives that achieve the same goal

Design's capabilities list is a starting point, not a constraint.

---

## References

- ADF-STAGES-SPEC.md (Universal exit criteria, stage boundary handoff)
- ADF-BRIEF-SPEC.md (Brief is primary input)
- ADF-INTENT-SPEC.md (Intent is North Star)
- ADF-PROJECT-TYPES-SPEC.md (Determines required outputs)
- ADF-DISCOVER-SPEC-v2.md (Discover stage outputs Brief)
- ADF-FOLDER-STRUCTURE-SPEC.md (docs/active/ convention)
- ADF-TAXONOMY.md (Terminology definitions)
- ADF-REVIEW-SPEC.md (Review mechanism)
