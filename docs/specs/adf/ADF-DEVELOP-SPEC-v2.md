---
type: "specification"
description: "Detailed specification for the Develop stage workflow"
version: "2.0.0"
updated: "2026-03-23"
supersedes: "ADF-DEVELOP-SPEC.md (v2.2.0)"
scope: "adf"
lifecycle: "active"
location: "docs/active/ADF-DEVELOP-SPEC-v2.md"
---

# ADF Develop Stage Specification

## Purpose

Define the Develop stage — the third stage in the ADF workflow where a validated design becomes a working implementation.

---

## Stage Overview

> **"Are we building it correctly?"**

Develop transforms a validated design into a working deliverable. This stage handles capability assessment, planning, environment setup, implementation, documentation, and structured closeout.

**Primary Deliverables (in sequence):**

| Order | Artifact | Content | Creates |
|-------|----------|---------|---------|
| 1 | `manifest.md` | Software dependencies to install | What to install |
| 2 | `capabilities.md` | MCP servers, skills, sub-agents, tools | What agent infrastructure is needed |
| 3 | `plan.md` | Implementation plan with phases/milestones | How to build it |
| 4 | `BACKLOG.md` | Atomic task list with status tracking | What to do |
| 5 | The deliverable | Code, artifact, or workflow | The actual thing |
| 6 | Documentation | README, API docs, usage guides | How to use it |

**Sequence matters.** Capabilities informs planning. Planning informs tasks. Do not create later artifacts until earlier ones are approved.

---

## Phase Model

**PLANNING PHASES (1-3):** Produce artifacts, proceed to review.

| Phase | Description | Exit Gate | Artifacts |
|-------|-------------|-----------|-----------|
| **1. Intake & Validation** | Ensure understanding, close loose ends | Human confirms understanding | — |
| **2. Capability Assessment** | Identify dependencies and capabilities needed | Human approves manifest + capabilities | manifest.md, capabilities.md |
| **3. Planning** | Create implementation plan and task breakdown | Agent approves plan + tasks | plan.md, BACKLOG.md |

**REVIEW + HARD GATE (Phase 4):** Validate plan, then get human approval.

| Phase | Description | Exit Gate | Artifacts |
|-------|-------------|-----------|-----------|
| **4. Review Loop & Approval** | Internal/external review, then human sign-off | No Critical/High issues + human approval | Updated planning artifacts |

**EXECUTION PHASES (5-8):** Require approved plan.

| Phase | Description | Exit Gate | Artifacts |
|-------|-------------|-----------|-----------|
| **5. Environment Setup** | Install dependencies, configure capabilities | Environment verified | — |
| **6. Build** | Implementation with testing + build-to-design verification | 95%+ tests pass, verification complete | The deliverable |
| **7. Documentation** | README, API docs, usage guides | Docs exist and accurate | Documentation |
| **8. Closeout** | Cleanup, verification, archive, seal | All criteria met, status.md sealed | — |

---

## Phase Boundary Protocol

Every phase transition requires context clearing to prevent accumulated drift and stale assumptions.

**Protocol (agent-driven):**

1. Agent completes phase work
2. Agent updates the **Handoff** block in `BACKLOG.md` (see format below)
3. Agent updates `status.md` with phase completion summary
4. **Agent commits all changes** (mandatory — not optional)
5. Agent updates `current_phase` in `BACKLOG.md` frontmatter
6. Agent moves completed tasks to Completed section in `BACKLOG.md`
7. Agent runs `/clear`
8. Agent re-reads artifacts fresh: `CLAUDE.md` → `status.md` → `BACKLOG.md` → `plan.md`
9. Agent confirms: **"Phase N complete. Starting Phase N+1. Here's what I see: [brief summary from handoff block]"**

**Why:** Multi-phase execution accumulates stale context. Agents carry assumptions forward that may no longer apply. Clearing context and re-reading from artifacts ensures each phase starts from ground truth, not memory.

### Handoff Block

The Handoff section lives at the top of `BACKLOG.md` (after frontmatter, before phase tables). It is **overwritten** at each phase boundary — only the current handoff matters.

**Required format:**

```markdown
## Handoff

| Field | Value |
|-------|-------|
| Phase | {completed phase name} |
| Status | Complete |
| Next | {next phase name} |
| Blocker | {blocker or "None"} |

**Done this phase:**
- {task ID}: {brief summary}
- {task ID}: {brief summary}

**Next phase requires:**
- {what to start, key dependencies, any setup needed}

**Build notes:**
- {decisions made, gotchas discovered, anything the next phase needs to know}
```

**Rules:**
- **Overwrite, don't append.** Each boundary replaces the previous handoff block.
- **Keep it short.** 10-20 lines max. This is orientation, not a journal.
- **Build notes are optional.** Omit the section if there's nothing worth noting.

---

## Inputs

What enters the Develop stage:

| Input | Source | Description |
|-------|--------|-------------|
| `design.md` | Design | Primary input — technical specification (consumed) |
| Supporting design docs | Design | architecture.md, data-model.md, etc. if >500 lines |
| `intent.md` | Discover | North Star — referenced throughout |
| `brief.md` | Discover | Contract — referenced for success criteria |
| Project classification | Brief | Type + modifiers determine deliverable shape |
| ADF specs | Environment layer | Develop spec, testing requirements |

---

## Outputs

What Develop produces:

| Output | Description | Location |
|--------|-------------|----------|
| `manifest.md` | Software dependencies, libraries, packages | `docs/active/manifest.md` |
| `capabilities.md` | Skills, tools, sub-agents, MCP servers | `docs/active/capabilities.md` |
| `plan.md` | Implementation plan — phases, milestones, approach | `docs/active/plan.md` |
| `BACKLOG.md` | Atomic task list with status tracking | `BACKLOG.md` (cross-stage) or `docs/active/BACKLOG.md` |
| Updated design docs | If gaps found during validation | `docs/design*.md` |
| The deliverable | Code, artifact, or workflow | Type-specific location |
| Documentation | README, API docs, usage guides | Project root + type-specific |

---

## Phase Details

### 1. Intake & Validation

**Purpose:** Ensure the development team fully understands the design before any work begins. Close all loose ends.

**Activities:**
- Read design.md and all supporting design artifacts
- Identify ambiguities, gaps, or open questions
- Use AskUserQuestion for clarification
- Validate understanding: "I read X as meaning Y — correct?"
- Close any loose ends from Design stage

**Agent role:** Active questioner. Challenge assumptions. Ensure 100% clarity before proceeding.

**Human role:** Answer questions, clarify intent, approve understanding.

**Exit signal:** Agent confirms: "I have full understanding. Ready to assess capabilities."

---

### 2. Capability Assessment

**Purpose:** Identify everything needed to build the deliverable — both software dependencies and agent capabilities.

**Sequence:** Create manifest.md first, then capabilities.md. Capabilities cannot be assessed until dependencies are known.

#### manifest.md — Software Dependencies

What needs to be installed:
- Languages/runtimes (Node.js, Python, Go, etc.)
- Frameworks (Next.js, FastAPI, etc.)
- Libraries/packages (with versions where critical)
- Infrastructure dependencies (databases, caches, etc.)
- Development tools (linters, formatters, test runners)
- External services (APIs, SaaS integrations)

#### capabilities.md — Agent Infrastructure

What the agent team needs to execute. **Required sections:**

| Section | Content | Example |
|---------|---------|---------|
| **MCP Servers** | Model Context Protocol servers for external integrations | Context7 (docs), Vercel (deploy), Supabase (db) |
| **Skills** | Specialized procedural knowledge from registry | frontend-design, webapp-testing, pdf |
| **Sub-agents** | Specialized agents for specific domains | ui-expert, backend-specialist |
| **CLIs & Tools** | External command-line tools and utilities | npm, git, playwright |
| **Testing Capabilities** | Test frameworks and validation tools | Jest, Playwright, axe-core |

**Testing capabilities MUST be identified in Phase 2.** The build agent needs to know upfront what testing tools are available. If missing, Phase 2 is incomplete.

**Registry Query Step (mandatory):**

Before documenting capabilities, query available resources:

1. **Read registry inventory** — `~/code/_shared/capabilities-registry/INVENTORY.md`
2. **Match to requirements** — Which available capabilities apply to this project?
3. **Identify gaps** — What's needed but not in registry? (manual specification required)
4. **Document source** — For each capability, note: registry path OR manual specification
5. **Write Registry Summary** — Include as the first section of capabilities.md

Without the summary, Phase 2 is incomplete.

**Agent role:** Query registry, research requirements from design, document comprehensively with sources.

**Human role:** Validate capability choices, approve or suggest alternatives.

**Exit signal:** Manifest and capabilities approved. Ready to plan.

---

### 3. Planning

**Purpose:** Create a comprehensive implementation plan and atomic task breakdown.

**Methodology:** Follow ADF-PLANNING-SPEC.md — the cross-cutting planning specification that defines the seven-step planning process (understand intent, decompose, organize phases, parallelization strategy, capability assessment, testing strategy, risk/contingency).

**Two outputs:**

#### plan.md — Implementation Plan

Structure and content per ADF-PLANNING-SPEC.md plan artifact format. For development projects, the plan MUST include:

- Testing Strategy (frameworks from capabilities.md, what gets tested at each tier, coverage targets — default 95%+, browser testing plan if applicable)
- Parallelization Strategy (independent work streams, agent assignments, coordination points)
- Capability Assessment summary (from Phase 2, with gap resolution status)

If the testing strategy section is missing or incomplete, Phase 3 is incomplete.

#### BACKLOG.md — Handoff + Atomic Task List

In Develop, BACKLOG.md uses the **full structure** with:
- Handoff block (overwritten at each phase boundary)
- Active Tasks table with all columns (ID, Task, Status, Acceptance Criteria, Testing, Depends, Capability)
- Upcoming section for next phase planning
- Completed section for traceability

**Key Develop requirements:**
- Every task has acceptance criteria and testing approach
- Capability column links to capabilities.md entries
- Progressive disclosure: read Handoff + Active, skip Completed unless investigating
- Task granularity: one agent, one session, verifiable completion

**Exit signal:** Plan and tasks drafted. Ready for review.

---

### 4. Review Loop & Approval

**Purpose:** Validate the plan and capability assessment through thorough review, THEN get human approval.

**Two-step process:**

#### Step 1: Review Loop

Invoke review per ADF-REVIEW-SPEC.md.

**What gets reviewed:**
- manifest.md
- capabilities.md
- plan.md
- BACKLOG.md

All artifacts reviewed together — they must align.

**Review focus:**
- Does the plan cover all design requirements?
- Are tasks atomic enough for single-agent execution?
- Are dependencies complete? Anything missing?
- Is the testing strategy sufficient?
- Are there parallelization opportunities not captured?
- Any risks not addressed?

**Review mechanism:** Review follows ADF-REVIEW-SPEC. Internal review is mandatory. External review is risk-driven, user-triggered.

**Exit condition (Step 1):** No Critical/High issues. Plan is executable.

#### Step 2: HARD GATE — Human Approval

After review completes, present all planning artifacts to human for approval.

**Agent presents:**
- manifest.md (dependencies)
- capabilities.md (skills/tools needed)
- plan.md (implementation approach + testing strategy)
- BACKLOG.md (atomic task breakdown)
- Review summary (issues resolved, reviewer feedback)

**Human evaluates:**
- Does this make sense for our context?
- Are the dependencies correct?
- Is the testing strategy appropriate?
- Any concerns or changes needed?

**Exit condition (Step 2):** Human approves: "Proceed with execution."

---

### 5. Environment Setup

**Purpose:** Get everything ready for build. No coding yet — just preparation.

**Activities:**
- Install dependencies from manifest.md
- Configure tools and capabilities from capabilities.md
- Set up project structure
- Configure testing framework
- Verify environment works (smoke test)

**Agent role:** Execute setup, verify each step.

**Verification:**
- All dependencies install successfully
- Development server runs
- Test framework executes
- Required capabilities are accessible

**Exit signal:** Environment verified. Ready to build.

---

### 6. Build

**Purpose:** Actually implement the deliverable with thorough automated testing.

**Approach: Test-Driven Development**

For each task:
1. Write tests first (where applicable)
2. Implement to pass tests
3. Verify acceptance criteria
4. Mark task complete

**Testing requirements:**
- Automated tests for all critical paths
- **95%+ pass rate minimum** before human testing
- No "ready for testing" when basic functionality fails
- Integration tests where components interact

**Build-to-Design Verification (after all tasks complete):**

Before proceeding to Phase 7, verify implementation against design:

1. Re-read design.md
2. For each major design requirement, identify where it's implemented
3. Simple checklist format:
   ```
   Design Requirement → Implementation
   - [ ] Two MCP tools (list_models, review) → external_review_server.py
   - [ ] Parallel execution → asyncio.gather in review()
   - [ ] Provider abstraction → providers/base.py + 2 implementations
   ```
4. Flag gaps: fix small ones, flag significant ones for human

Not a full audit. A structured sanity check: "did we build what we designed?"

**What gets maintained during Build:**
- `BACKLOG.md` — Updated as tasks complete
- `status.md` — Updated by primary agent (not sub-agents)
- `docs/active/backlog.md` — New ideas/improvements captured
- Decision log (in plan.md) — Key implementation decisions documented

**Critical rule:** Do NOT ask for human testing until:
- All tasks marked complete
- Automated tests pass (95%+ rate)
- Basic functionality verified
- Agent has done thorough self-validation
- Build-to-design verification complete

**Exit signal:** All tasks complete. Automated tests pass. Build-to-design verification complete. Ready for documentation.

---

### 7. Documentation

**Purpose:** Write documentation while the build is fresh. Don't defer — context degrades rapidly.

**Activities:**
- Write/update README.md (installation, usage, key features)
- Create API docs or tool reference (if applicable)
- Document configuration options
- Write testing instructions

**Documentation by project type:**

| Type | Required Docs |
|------|---------------|
| App | README (install, run, configure), architecture notes |
| MCP Server | README (install, .mcp.json wiring, tool reference), testing instructions |
| Workflow | README (trigger setup, configuration), runbook |
| Artifact | README (usage, inputs/outputs), format spec |

**Exit signal:** Documentation exists, is accurate, enables a new user to use the deliverable.

---

### 8. Closeout

**Purpose:** Structured verification, cleanup, and seal.

**Ordered checklist:**

#### 8.1 Cleanup
- [ ] .gitignore updated (venv, node_modules, __pycache__, build artifacts)
- [ ] Transient files deleted (temp outputs, debug logs)
- [ ] No secrets in repo
- [ ] No commented-out code blocks

#### 8.2 Success Criteria Gate
- [ ] Load brief.md → success criteria
- [ ] Map each criterion to evidence (code location, test result, feature)
- [ ] Mark each: met / partial (with explanation) / not met (BLOCKS completion)
- [ ] Document mapping in status.md

#### 8.3 Artifact Lifecycle
- Keep in `docs/`: intent.md, brief.md, design.md (cross-stage reference)
- Archive to `docs/archive/`: plan.md, BACKLOG.md, manifest.md, capabilities.md
- Keep in project: deliverable, tests, documentation

#### 8.4 Commit Verification
- [ ] No uncommitted changes
- [ ] Commit history shows atomic commits (not one giant commit)

#### 8.5 status.md Update (THE SEAL)
- Mark stage complete
- Include structured stage handoff (per ADF-STAGES-SPEC.md Stage Boundary Handoff Protocol)
- This is the LAST step

---

## Testing Strategy

Testing is not optional. It's core to Develop.

### Three-Tier Testing Model

| Tier | What | When | Tools |
|------|------|------|-------|
| **Tier 1: Automated** | Unit, integration, E2E via frameworks | During build | Jest, Pytest, Vitest, Playwright |
| **Tier 2: Browser/Real-world** | Interactive testing in browser or inspector | After Tier 1 passes | Claude in Chrome, MCP Inspector |
| **Tier 3: Manual** | User acceptance, edge cases, subjective validation | After Tier 2 passes | Human testing |

### Testing by Project Type

| Type | Automated Focus | Browser Testing? | Manual Testing? |
|------|-----------------|------------------|-----------------|
| App | Unit, integration, E2E, accessibility | Yes (Claude in Chrome) | Yes (user acceptance) |
| MCP Server | Tool handlers, params, error paths | Yes (MCP Inspector) | Yes (tool validation) |
| Workflow | Unit, integration, error handling | No (unless UI) | Yes (trigger test) |
| Artifact | Validation, format, content accuracy | No | Yes (visual inspection) |

### Progressive Testing

Test results feed into each other:
1. Tier 1 must pass (95%+ rate) before Tier 2 begins
2. Tier 2 must pass before Tier 3 begins
3. Issues found in later tiers trigger fixes and re-testing from Tier 1

**Critical rule:** Do NOT mark build complete until all three tiers complete with human confirmation of acceptance.

---

## Commit Cadence

**Hard requirements:**
- Commit after every task completion
- Commit at every phase boundary
- Commit before requesting human input
- Conventional format: `type(scope): description`

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

### Develop-Specific Criteria

- [ ] All three testing tiers complete (automated, browser, manual)
- [ ] Tier 1: Automated tests pass (95%+ rate)
- [ ] Tier 2: Browser/real-world testing complete
- [ ] Tier 3: Manual validation complete with human acceptance
- [ ] Build-to-design verification complete
- [ ] Success criteria from brief mapped to evidence (all met)

### Type-Specific Criteria

| Type | Additional Criteria |
|------|---------------------|
| App | Browser testing complete, accessibility checked |
| MCP Server | Inspector testing complete |
| Workflow | Error handling tested |
| Artifact | Format validation passes |

**The handoff test:** Human tests the most basic functionality. If it fails, Develop is not done.

---

## Context Loading

### What the Primary Agent Needs

1. **Design package** — design.md + supporting docs (consumed)
2. **Intent** — North Star (referenced)
3. **Brief** — Success criteria (referenced)
4. **This spec** — Stage workflow
5. **Current state** — status.md

### Context Map (for CLAUDE.md)

```markdown
## Context Map

| File | Load When | Purpose |
|------|-----------|---------|
| intent.md | Always | North Star |
| design.md | Develop stage | Primary input |
| docs/active/plan.md | Develop stage (after created) | Implementation guide |
| BACKLOG.md | Develop stage (after created) | Task tracking |
| ADF-DEVELOP-SPEC-v2.md | Develop stage (reference) | Stage workflow |
```

---

## Sub-Agent Coordination

Develop makes heavy use of sub-agents for parallelization.

### Primary Agent Responsibilities

- Orchestrate overall workflow
- Assign tasks to sub-agents
- Update status.md
- Coordinate dependencies between tasks
- Final validation before human handoff

### Sub-Agent Responsibilities

- Execute assigned tasks
- Run tests for their work
- Mark tasks complete in BACKLOG.md
- Report blockers to primary agent
- Do NOT update status.md

### Parallelization Rules

- Only parallelize independent tasks
- Tasks with dependencies execute sequentially
- Primary agent monitors all parallel work
- Merge/integration points are synchronization barriers

---

## References

- ADF-PLANNING-SPEC.md (Cross-cutting planning methodology — seven-step process)
- ADF-STAGES-SPEC.md (Universal exit criteria, stage boundary handoff)
- ADF-REVIEW-SPEC.md (Review mechanism — cycles, severity, stop conditions)
- ADF-DESIGN-SPEC-v2.md (Design is primary input)
- ADF-BRIEF-SPEC.md (Success criteria reference)
- ADF-INTENT-SPEC.md (North Star reference)
- ADF-PROJECT-TYPES-SPEC.md (Deliverable shape)
- ADF-FOLDER-STRUCTURE-SPEC.md (docs/active/ convention)
- ADF-TAXONOMY.md (Terminology)
