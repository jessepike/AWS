---
type: "specification"
description: "Defines the ADF stage workflow model — five stages, exit criteria, handoff protocol, artifact lifecycle"
version: "2.0.0"
updated: "2026-03-23"
scope: "adf"
lifecycle: "active"
supersedes: "ADF-STAGES-SPEC v1.4.0"
---

# ADF Stages Specification

## Purpose

Define the minimal stage workflow for agentic projects — applicable to software development, presentations, reports, or any structured work.

## Model Overview

ADF operates in two modes that form a continuous cycle:

```
        ┌──────── ASSUMPTION MODE ────────────────────────────┐
        │  Building on what we think is true                  │
        │                                                     │
        │  ┌──────────┐ ┌────────┐ ┌─────────┐ ┌─────────┐   │
        │  │ Discover │→│ Design │→│ Develop │→│ Deliver │───┼──→ ship it
        │  └──────────┘ └────────┘ └─────────┘ └─────────┘   │
        │       ↑                                             │        │
        └───────┼─────────────────────────────────────────────┘        │
                │  real-world evidence seeds next cycle                 ↓
                │                                           ┌─────────────────┐
                └───────────────────────────────────────────│ Operate & Learn │
                                                            │  (Evidence Mode)│
                                                            └─────────────────┘
```

**Assumption Mode** (Discover → Deliver): building from a model of the world — what we think the problem is, how we think it should be solved.

**Evidence Mode** (Operate & Learn): activated by shipping. Real use generates evidence about which assumptions held and what wasn't anticipated. That evidence seeds the next cycle.

The loop is continuous for living systems. One-shot artifacts (presentations, reports) complete at Deliver.

---

## Stages

### DISCOVER

> **"What are we trying to accomplish?"**

| Aspect | Description |
|--------|-------------|
| **Inputs** | Initial concept, constraints, domain context |
| **Setup needs** | Validation prompts, research tools |
| **Outputs** | `intent.md`, `brief.md` |
| **Exit criteria** | Intent is crystal clear; success criteria defined |

**Intent.md is the #1 artifact.** All agents, all humans, all stages must align to intent.

---

### DESIGN

> **"How will we approach it?"**

| Aspect | Description |
|--------|-------------|
| **Inputs** | `intent.md`, `brief.md` |
| **Setup needs** | Decision frameworks, reference materials |
| **Outputs** | Approach decisions (tools, structure, dependencies) |
| **Exit criteria** | We know what we're building and how |

**Note:** "Approach" is project-type dependent:
- Software → architecture, stack, data model
- Presentation → outline, visual style, tool choice
- Report → structure, sources, format

---

### DEVELOP

> **"Are we building it correctly?"**

| Aspect | Description |
|--------|-------------|
| **Inputs** | Design decisions, `intent.md` (reference) |
| **Setup needs** | Environment, tools, detailed plan/tasks |
| **Outputs** | The thing itself (code, doc, deck, etc.) |
| **Exit criteria** | Following good practices; making progress toward intent |

**Not just software.** Develop = executing the work, whatever form it takes.

---

### DELIVER

> **"Is this increment done and usable?"**

| Aspect | Description |
|--------|-------------|
| **Inputs** | Built artifact |
| **Setup needs** | Deployment/distribution config, documentation |
| **Outputs** | Usable, accessible deliverable |
| **Exit criteria** | User can access/use it; MVP loop closes |

**Milestone-based.** Deliver marks completion of an increment, not necessarily end of project. For living systems, shipping activates the Operate & Learn loop.

---

### OPERATE & LEARN

> **"Is this working well, and what should change?"**

| Aspect | Description |
|--------|-------------|
| **Inputs** | Delivered system in real use, `intent.md`, `brief.md` |
| **Mode** | Evidence Mode — activated by shipping, runs continuously |
| **Outputs** | Signal log, synthesis reports, BACKLOG.md entries, cycle decision |
| **Loop trigger** | Synthesis + Cycle Decision → continue, fix in place, new Discover, or retire |

**Not a sequential stage** — a loop closure mechanism. Shipping activates it; real-world evidence seeds the next Discover cycle. Applies to living systems only (apps, MCP servers, workflows, agents). One-shot artifacts complete at Deliver.

See `ADF-OPERATE-SPEC.md` for full specification.

---

## Cross-Stage Artifacts

Some artifacts persist across all stages:

| Artifact | Purpose | Behavior |
|----------|---------|----------|
| `intent.md` | North Star — why we're doing this | Created in Discover, stable thereafter |
| `status.md` | Session state — where we left off | Updated every session, all stages |
| `BACKLOG.md` | Task tracking and phase handoff | Minimal in Discover/Design, full in Develop/Deliver |
| `decisions.md` | Decision log (new) | Records key choices and rationale |
| `CLAUDE.md` / `AGENTS.md` | Context manifest — what to load | Evolves with project, references status.md |
| `docs/active/` | Stage planning workspace | Created in Develop, archived at stage completion |
| `.ctx/` | Ephemeral workspace | Temporary session artifacts |

---

## Artifact Lifecycle

Each stage produces artifacts that fall into three categories:

| Category | Definition | Behavior at Stage Transition |
|----------|------------|------------------------------|
| **Deliverable** | Final outputs that carry forward | Remain active in project context |
| **Working** | Ephemeral artifacts created during exploration/iteration | Archive to `docs/archive/` |
| **Reference** | Supporting materials that remain useful | Remain active in `docs/` |

### Artifact Lifecycle by Stage

| Stage | Deliverables (Keep Active) | Working Artifacts (Archive) |
|-------|---------------------------|----------------------------|
| **Discover** | `intent.md`, `brief.md` | Concept briefs, discovery briefs, research spikes |
| **Design** | `design.md`, `BACKLOG.md`, decision records | Draft designs, spike reports, exploration notes |
| **Develop** | Implementation (code/artifacts), tests | Planning documents from `docs/active/` |
| **Deliver** | Deployment artifacts, handoff docs | Deployment notes, validation reports |
| **Operate & Learn** | `docs/operate/observations.md`, synthesis reports | N/A — all outputs are persistent signals or backlog entries |

### Stage Transition Cleanup Protocol

When transitioning between stages:

1. **Identify deliverables** — verify these artifacts are final and complete
2. **Archive working artifacts** — move to `docs/archive/` with naming: `docs/archive/YYYY-MM-DD-<artifact-name>.md`
3. **Verify active context** — only deliverable and reference artifacts remain accessible
4. **Update status.md** — document what was archived and why

---

## Stage Transitions

Each transition requires the completing stage to execute the **Stage Boundary Handoff Protocol** (below), plus stage-specific setup:

| Transition | Setup Activity |
|------------|----------------|
| Init → Discover | Scaffold folders, load rules, prep validation prompts |
| Discover → Design | Handoff protocol, verify intent clarity, prep decision frameworks |
| Design → Develop | Handoff protocol, environment ready, tools installed, plan created |
| Develop → Deliver | Handoff protocol, deployment config, documentation |
| Deliver → Operate & Learn | Milestone seal complete; create `docs/operate/observations.md`; run Activation phase (intent alignment check + observation targets) |
| Operate & Learn → Discover | Cycle Decision: new Discover triggered; synthesis seeds updated `brief.md` |

---

## Universal Exit Criteria

Every stage must satisfy these before transitioning. Stage-specific exit criteria (defined in each stage spec) layer on top.

- [ ] Primary deliverable(s) exist with required content
- [ ] No Critical or High issues open (post-review)
- [ ] Alignment verified with intent.md and brief.md
- [ ] All work committed (atomic commits, no uncommitted changes)
- [ ] Documentation appropriate to deliverable exists
- [ ] Workspace cleanup complete (no transients, .gitignore current)
- [ ] status.md updated with stage completion (THE SEAL — last step)
- [ ] Human sign-off obtained

---

## Stage Boundary Handoff Protocol

When transitioning between stages, the completing agent:

1. Completes all stage-specific exit criteria
2. **Executes Stage Transition Cleanup Protocol**
   - Archive working artifacts to `docs/archive/`
   - Verify only deliverables and reference artifacts remain active
3. Updates status.md with structured stage handoff:
   - **What was produced** — deliverable summary + key files
   - **What was archived** — list of archived artifacts and rationale
   - **Success criteria status** — from brief.md
   - **Known limitations / deferred items**
   - **Read order for next stage agent**
4. Commits with `chore({stage}): stage complete — {summary}`
5. Runs `/clear`

The next stage agent starts by reading `CLAUDE.md` → `status.md` (which contains the handoff).

---

## Stage Handoff Template

When updating status.md at stage transition, use this structure for the handoff block:

```markdown
## Stage Handoff: {Stage Name} → {Next Stage Name}

**Date:** YYYY-MM-DD

### Deliverables Produced
- [Artifact name with path] — [Brief description]
- [Artifact name with path] — [Brief description]

### Archived Artifacts
- [Artifact name] → `docs/archive/YYYY-MM-DD-{name}.md` — [Why archived]
- [Artifact name] → `docs/archive/YYYY-MM-DD-{name}.md` — [Why archived]

### Success Criteria Status
[Reference brief.md criteria and note completion/deferrals]
- [Criterion 1]: ✅ Complete / ⏸️ Deferred / ❌ Not met
- [Criterion 2]: ✅ Complete / ⏸️ Deferred / ❌ Not met

### Known Limitations
- [Technical constraints identified]
- [Deferred features or scope]
- [Open questions for next stage]

### Read Order for Next Stage
1. `intent.md` — North Star reference
2. [Primary deliverable] — [Why read this]
3. [Secondary artifact] — [Why read this]
4. `status.md` — Current state and context
```

**Usage:** All stages use this template. Stage-specific transition prompts provide guidance on what to include per stage.

---

## Design Principles

**Inclusive, not prescriptive:** Stages apply to any project type, not just software.

**Intent-aligned:** Every stage references back to `intent.md` as the source of truth.

**Pull-based:** Capabilities exist in the environment layer; stages pull what they need.

**Minimal gates:** Exit criteria are clarity checks, not bureaucratic approvals.

**Cycles, not versions:** For living systems, Deliver is not the end — it's the beginning of the evidence phase. Each cycle produces a stronger next cycle because it starts from observed reality rather than assumptions.

---

## References

- ADF-GLOBAL-PRIMITIVES-v0.1.md
- ADF-GLOBAL-CLAUDE-MD-SPEC.md
- ADF-OPERATE-SPEC.md (Operate & Learn full specification)
- ADF-ARCHITECTURE-SPEC.md
