---
type: "specification"
description: "Defines the planning methodology — how work gets decomposed, organized, and prepared for execution"
version: "1.0.0"
updated: "2026-02-09"
scope: "adf"
lifecycle: "reference"
location: "adf/ADF-PLANNING-SPEC.md"
---

# ADF Planning Specification

## Purpose

Define the planning methodology used across all ADF stages and project types. This spec owns the **how** of planning — when plans are needed, how work gets decomposed, how tasks get organized for parallelization, how capability gaps get identified, and how testing strategy gets integrated. Stage-specific specs own the **when** — at what point planning occurs within their workflow.

---

## Scope

Planning is cross-cutting. It applies to:

- **Development projects:** Implementation planning within the Develop stage (Phases 2-3)
- **Non-development projects:** Consulting engagements, content calendars, business operations, board work
- **Any body of work** that requires decomposition from intent into executable units

This spec is universal. Stage-specific and project-type-specific adaptations are noted where they differ.

---

## Core Principle

**Planning is decomposition of intent into executable work, organized for parallel execution by agents with verified capabilities.**

A good plan answers five questions:

1. **What** needs to be done? (task decomposition)
2. **In what order?** (sequencing and dependencies)
3. **By whom?** (agent assignment and capability matching)
4. **How do we know it's done?** (acceptance criteria and testing)
5. **What's missing?** (capability gap analysis)

---

## When Planning Is Needed

Not all work requires a plan document. The planning overhead should match the work complexity.

### Decision Matrix

| Condition | Planning Approach | Artifacts Produced |
|-----------|-------------------|-------------------|
| 1-5 simple, independent tasks | **No plan.** Flat task list. | tasks.md only |
| 6-10 tasks with some dependencies | **Lightweight plan.** Group into phases. Brief approach notes. | Minimal plan.md + tasks.md |
| 10+ tasks, multiple domains, or multi-agent execution | **Full plan.** Phases, capability assessment, testing strategy, parallelization strategy. | Full plan.md + tasks.md + capabilities.md |
| External stakeholders or handoffs | **Full plan.** Always. Regardless of task count. | Full plan.md + tasks.md |
| Timeline > 2 weeks | **Full plan.** Always. | Full plan.md + tasks.md |

### Escalation Triggers

If any of these conditions emerge during planning, escalate to the next level:

- Dependencies discovered between what appeared to be independent tasks
- Capability gaps identified (skills, tools, or agents not available)
- Work spans multiple domains requiring different agent skill sets
- Risk areas identified that need mitigation strategies
- Human approval gates needed mid-execution

---

## Planning Process

### Step 1: Understand the Intent

Before decomposing work, confirm understanding of:

- **What success looks like** — acceptance criteria for the overall body of work
- **Constraints** — timeline, resources, dependencies, budget
- **Scope boundaries** — what's explicitly in and out

For development projects, this maps to ADF-DEVELOP-SPEC Phase 1 (Intake & Validation). For non-development work, the planner asks clarifying questions until intent is confirmed.

**Exit:** "I understand the goal, the constraints, and the boundaries."

### Step 2: Decompose Into Work Units

Break the intent into atomic tasks. Each task must be:

- **Completable by one agent in one session** (the atomic test)
- **Independently verifiable** — clear acceptance criteria
- **Scoped to a single skill domain** where possible (front-end, back-end, data, etc.)

#### Decomposition Rules

1. **Start broad, then narrow.** First identify major work streams (domains), then break each stream into phases, then break phases into tasks.
2. **Group by skill set.** Tasks requiring the same capabilities belong together. This enables parallelization — one agent (or agent type) handles an entire group.
3. **Identify the dependency graph.** Which tasks block which? Map explicitly. Independent groups can run in parallel.
4. **Separate deterministic from reasoning work.** Some tasks need intelligence (design decisions, complex debugging). Others are mechanical (file creation, config changes, boilerplate). Route accordingly — cheaper models for deterministic work, stronger models for reasoning.

#### Task Granularity Guidance

From ADF-TASKS-SPEC:

- **Too large:** "Build the authentication system"
- **Right size:** "Implement login endpoint with JWT validation"
- **Too small:** "Add semicolon to line 42"
- **Right size:** "Fix linting errors in auth module"

**Additional guidance for parallelized work:**

- **Too coupled:** "Implement login endpoint and wire up the UI form" (two domains, one task)
- **Right decomposition:** Task A: "Implement login endpoint" (back-end agent) + Task B: "Build login form component" (front-end agent) — these run in parallel, integrate later

### Step 3: Organize Into Phases

Phases are optional groupings. Use them when:

- **Sequential dependencies exist** between task groups ("Phase 2 can't start until Phase 1 completes")
- **Logical milestones** make sense ("Phase 1: Core structure, Phase 2: Features, Phase 3: Polish")
- **Different agent assignments** per phase ("Phase 1: one back-end agent, Phase 2: three front-end agents in parallel")
- **Human approval gates** are needed between groups
- **Work exceeds ~8 tasks** and needs visual/cognitive organization

When phases aren't needed (flat task list is fine):

- All tasks are independent or have simple linear dependencies
- Fewer than ~8 tasks
- Single agent executing sequentially
- Low complexity, clear path

### Step 4: Parallelization Strategy

**This is a first-class planning concern, not an afterthought.**

For every plan, explicitly identify:

#### 4a. Independent Work Streams

Which task groups have zero dependencies on each other? These are parallelization candidates.

```
Example:
├── Stream A: Database schema + migrations (back-end agent)
├── Stream B: API endpoint stubs (back-end agent)  
├── Stream C: UI component library (front-end agent)
└── Stream D: Test infrastructure setup (DevOps agent)

Streams A, B, C, D can all run in parallel.
Stream E (API integration tests) depends on A + B completing first.
```

#### 4b. Agent Assignment

For each stream or phase, specify:

| Stream/Phase | Agent Type | Model Tier | Parallelizable? | Depends On |
|-------------|-----------|-----------|-----------------|-----------|
| DB schema | Back-end specialist | Sonnet | Yes — independent | None |
| API stubs | Back-end specialist | Sonnet | Yes — independent | None |
| UI components | Front-end specialist | Sonnet | Yes — independent | None |
| Test infra | DevOps specialist | Haiku | Yes — independent | None |
| Integration tests | Test specialist | Sonnet | After A+B | Streams A, B |

#### 4c. Coordination Points

Where do parallel streams need to synchronize?

- **Integration boundaries:** Where front-end meets back-end (API contracts must be agreed before parallel work begins)
- **Shared resources:** Database schema must be stable before multiple agents write queries against it
- **Review gates:** All parallel work in a phase completes before review begins

#### 4d. Task Chunking by Skill Set

**Enforce grouping tasks by the capabilities they require.** This is how you achieve efficient parallelization:

- All CSS/styling tasks → one front-end agent session
- All database migration tasks → one back-end agent session
- All test-writing tasks → one testing agent session

The planning agent must explicitly state: "These N tasks are grouped because they require [capability] and can be assigned to a single agent session."

### Step 5: Capability Assessment

**This is the planning agent's FIRST job — before organizing tasks into phases, before parallelization strategy. Enumerate what's needed, then verify availability.**

Agents have a documented tendency to skip or gloss over capability assessment and jump straight to execution, improvising around missing capabilities without flagging the gap. This step exists to prevent that failure mode. **The agent must not assume it can work around a missing capability. It must surface the gap explicitly.**

#### 5a. Inventory — "What do I need?"

For each task or task group, enumerate:

- **Agent skills required** (front-end design, Python, testing, database, etc.)
- **Tools required** (MCP servers, CLIs, APIs, frameworks, etc.)
- **Model tier required** (Haiku for mechanical work, Sonnet for moderate reasoning, Opus for complex planning)
- **Custom subagents or agent teams** (per Claude Code agent architecture — specialized agents with custom system prompts, tool restrictions, model selection)

Produce a full requirements list before proceeding. Do not filter or assume availability.

#### 5b. Match — "What's available?"

Query the capabilities registry and available resources:

1. Read registry inventory: `~/code/_shared/capabilities-registry/INVENTORY.md`
2. Check Claude Code subagents: `.claude/agents/` (project and user level)
3. Check Claude Code skills: `.claude/commands/` and project skills
4. Check MCP servers: `.mcp.json` configuration
5. For each requirement, report: **Available** (with source path) or **Not Found**

Produce a clear ledger:

| # | Required Capability | Type | Available? | Source |
|---|---------------------|------|-----------|--------|
| 1 | Python testing (pytest) | Skill | ✅ Yes | registry: active/skill/testing |
| 2 | Front-end design (Tailwind) | Skill | ✅ Yes | registry: active/skill/frontend-design |
| 3 | GraphQL schema generation | Tool | ❌ No | — |
| 4 | Database migration agent | Subagent | ❌ No | — |

#### 5c. Gap Resolution — HARD GATE (User Interaction Required)

**For every "Not Found" item, the agent MUST stop and present options to the user.**

The agent does not:
- Silently work around the gap
- Assume it can handle the work without the capability
- Proceed without user input

The agent presents each gap with resolution options:

```
GAP IDENTIFIED: GraphQL schema generation tool

Impact: Blocks Stream C (API layer) — 4 tasks depend on this capability.

Options:
  (a) I search for an existing skill/tool that fits (web search + registry scan)
  (b) We build this capability now (requires a separate development effort)
  (c) You provide an alternative approach or tool
  (d) We proceed without it — I flag the risk and note manual effort required

Which approach for this gap?
```

**Rules:**
- Every gap gets its own resolution decision. No batching "we'll figure it out later."
- The agent can continue planning other parts of the work while gaps are being resolved.
- **The plan CANNOT be approved** (hard gate — Develop Phase 4, or equivalent for non-dev projects) until all capability gaps have a resolution path with user sign-off.
- Resolved gaps are documented in the plan's Capability Assessment section with the chosen resolution.
- If the user chooses option (a), the agent actively searches for suitable capabilities and presents findings before proceeding.

#### 5d. Gap Report (Summary for Work Manager)

After resolution, produce a summary:

| # | Gap | Impact | Resolution | Status |
|---|-----|--------|-----------|--------|
| 1 | GraphQL schema tool | Blocks Stream C | User chose: search for existing tool → found X, installing | Resolving |
| 2 | DB migration subagent | Blocks Phase 2 | User chose: build custom subagent → backlogged as prerequisite | Blocked |

**This report surfaces to the Work Manager as a dependency.** The Work Manager tracks gap resolution status and blocks plan approval until all gaps are resolved or explicitly accepted as risks.

### Step 6: Testing Strategy

**Every plan must define how completion will be verified.**

#### 6a. For Development Projects

Per ADF-DEVELOP-SPEC, plans must specify:

- **Test framework** (Jest, Pytest, Vitest, Playwright, etc.)
- **What gets tested at each tier:**
  - Tier 1: Automated (unit, integration, E2E)
  - Tier 2: Browser/real-world (Claude in Chrome, MCP Inspector)
  - Tier 3: Manual (human acceptance)
- **Coverage target** (default: 95%+ automated pass rate before human testing)
- **Browser testing plan** (if applicable)

Testing capabilities must be identified in the capability assessment (Step 5).

#### 6b. For Non-Development Projects

Define verification method per task or phase:

- **Acceptance criteria:** What does "done" look like?
- **Reviewer:** Who checks quality? (cross-cutting reviewer agent, human, external)
- **Validator:** What confirms completion? (cross-cutting validator agent checking criteria)

#### 6c. Validation Integration

Per the layers-and-rings model: validation is a ring, not a stage. The plan must specify:

- **Within-phase validation:** How do we know individual tasks are complete? (agent self-check, automated tests, acceptance criteria verification)
- **Between-phase validation:** What must be true before the next phase begins? (all tasks done, tests pass, review complete)
- **End-of-plan validation:** How do we know the entire plan's intent has been achieved? (build-to-design verification, success criteria gate)

### Step 7: Risk and Contingency

For full plans only. Identify:

- **Known risks** (technology unknowns, dependency on external inputs, timeline pressure)
- **Mitigation approaches** (spikes for unknowns, fallback options, scope reduction levers)
- **Decision points** ("If X doesn't work by Phase 2, we pivot to Y")

---

## Plan Artifact Structure

When a plan document is warranted (per the Decision Matrix above):

### plan.md — Required Sections

```markdown
---
project: "[Project Name]"
stage: "[Current Stage]"
updated: "YYYY-MM-DD"
---

# Plan

## Overview
What we're building/doing. Approach summary. Link to intent/design if applicable.

## Phases

### Phase 1: [Name]
- **Goal:** [What this phase accomplishes]
- **Tasks:** [Count] tasks ([link to tasks.md section])
- **Agent assignment:** [Who executes — agent type, model tier]
- **Parallelizable:** [Yes/No, with what other phases]
- **Dependencies:** [What must complete before this phase starts]
- **Acceptance criteria:** [How we know this phase is done]

### Phase 2: [Name]
[Same structure]

## Parallelization Strategy
Which streams run in parallel. Coordination points. Integration boundaries.

## Capability Assessment
Summary of required vs. available capabilities. Gap report if applicable.

## Testing Strategy
Framework, tiers, coverage targets. What gets tested how.

## Risk Areas
Known risks, mitigations, decision points.

## Decision Log
[Updated during execution — key choices with rationale]
```

### Minimal plan.md (Lightweight Plans)

```markdown
---
project: "[Project Name]"
updated: "YYYY-MM-DD"
---

# Plan

## Approach
[2-3 sentences on how we'll tackle this]

## Phases
1. **[Phase Name]:** [Brief description, task count]
2. **[Phase Name]:** [Brief description, task count]

## Notes
[Any risks, dependencies, or decisions worth capturing]
```

---

## Relationship to tasks.md

The plan produces tasks. Tasks live in tasks.md per ADF-TASKS-SPEC.

| Plan Element | tasks.md Mapping |
|-------------|-----------------|
| Phase → Tasks | Tasks grouped by phase (Active Tasks, Upcoming sections) |
| Dependencies | `Depends` column in task table |
| Agent assignment | `owner_type` / `owner_id` (from Work OS entity model) |
| Acceptance criteria | `Acceptance Criteria` column |
| Capability requirements | `Capability` column linking to capabilities.md |
| Testing approach | `Testing` column |

**The plan is the "why and how." tasks.md is the "what and status."** They are complementary, not redundant.

---

## Relationship to Other Specs

| Spec | Relationship |
|------|-------------|
| ADF-DEVELOP-SPEC | Planning occurs in Develop Phases 2-3. This spec defines the methodology; Develop spec defines the workflow context. |
| ADF-TASKS-SPEC | Plans produce tasks. Tasks.md structure is defined by Tasks spec. |
| ADF-BACKLOG-SPEC | Backlog items may be promoted into a plan. Backlog is pre-planning; plan is post-commitment. |
| ADF-REVIEW-SPEC | Plans undergo review (Develop Phase 4). Review spec defines the mechanism. |
| ADF-STAGES-SPEC | Planning applies within any stage, but is heaviest in Develop. |
| Work OS Brief | Plans, phases, and tasks map to Work OS entity hierarchy: Project → Plan → Phase → Task. |

---

## Cross-Cutting Agent Integration

Planning interacts with cross-cutting capability teams:

| Agent Team | Planning Touchpoint |
|-----------|-------------------|
| **Validator** | Plan specifies validation criteria. Validators check completion against those criteria during and after execution. |
| **Reviewer** | Plan undergoes review before execution (per ADF-REVIEW-SPEC). Reviewers also check quality within phases. |
| **Improver** | Post-execution, improver agent reviews plan vs. actuals to identify process improvements. |

These agents are dispatched to the plan's context — they don't live inside the planning process. The planning agent specifies *what* needs to be validated/reviewed; the cross-cutting teams handle *how*.

---

## Anthropic-Aligned Patterns

This spec incorporates patterns from Anthropic's agentic best practices:

| Anthropic Pattern | Planning Spec Application |
|------------------|--------------------------|
| **Orchestrator-Workers** | Plan defines the orchestration. Work Manager dispatches to worker agents per plan. |
| **Parallelization (Sectioning)** | Step 4 — explicit parallelization strategy with independent work streams. |
| **Subagent isolation** | Each parallel stream gets its own agent context. Prevents context window exhaustion. |
| **Task decomposition (DAG)** | Dependency graph in Step 2. Phases encode the DAG structure. |
| **Explore, Plan, Code, Commit** | Planning is the "Plan" phase. Explore happens in Intake/Validation. Code happens in Execution. |
| **Context management** | Phase boundaries trigger `/clear` and re-read (per ADF-DEVELOP-SPEC Phase Boundary Protocol). Plan persists on disk; context is disposable. |
| **Model tiering** | Step 4b — explicit model tier assignment. Haiku for mechanical work, Sonnet for moderate, Opus for strategic. |
| **Skills & custom subagents** | Capability assessment (Step 5) maps to Claude Code subagents and skills registry. |

---

## Planning Agent Skill Profile

The planning agent requires:

### Core Skills

- **Intent comprehension** — understand what success looks like from design docs, briefs, or verbal direction
- **Work decomposition** — break intent into atomic, verifiable tasks
- **Dependency mapping** — identify sequencing constraints and parallelization opportunities
- **Sizing** — estimate effort (S/M/L per ADF-BACKLOG-SPEC definitions)
- **Capability matching** — map tasks to required skills, tools, and agent types
- **Gap identification** — detect when required capabilities aren't available
- **Testing strategy** — define verification approach per task and per phase
- **Risk assessment** — flag known unknowns and propose mitigations

### Tools & Access

- **Capabilities registry** — query available skills, tools, agents
- **Project artifacts** — read design docs, briefs, intent docs, existing tasks/backlogs
- **Work OS** (when available) — query project status, existing task state, portfolio context

### Model Tier

Planning requires moderate-to-high reasoning. **Sonnet minimum.** For complex multi-stream plans with significant architectural decisions, **Opus recommended.**

---

## Validation Criteria

A well-formed plan:

- [ ] Matches a planning level from the Decision Matrix (no over/under-planning)
- [ ] Every task has acceptance criteria
- [ ] Every task has a testing/verification approach
- [ ] Dependencies are explicitly mapped (no implicit assumptions)
- [ ] Parallelization opportunities identified and documented
- [ ] Agent assignments specified (type + model tier)
- [ ] Capability gaps identified and reported (or confirmed: none)
- [ ] Phase boundaries have clear entry/exit criteria
- [ ] Aligns with intent.md / brief.md / design.md (where applicable)
- [ ] Testing strategy defined (framework, tiers, coverage targets for dev projects)

---

## Anti-Patterns

| Anti-Pattern | Why It Fails | Correct Approach |
|-------------|-------------|-----------------|
| Monolithic task list with no grouping | Agents lose context, no parallelization possible | Group by skill set and domain into phases |
| All tasks sequential when many are independent | Wastes time, doesn't leverage parallel agents | Map dependency graph; parallelize independent streams |
| Missing acceptance criteria | "Done" is ambiguous; validator can't check completion | Every task specifies what "done" looks like |
| Plan without capability check | Agents attempt tasks they can't complete; failures at runtime | Always run capability assessment before execution |
| Over-planning simple work | 3 tasks don't need a full plan document | Use the Decision Matrix; match overhead to complexity |
| Skipping testing strategy | Quality issues surface late; rework is expensive | Define verification approach during planning, not after build |
| Coupling tasks across skill domains | Blocks parallelization; agent needs multiple skill sets | One task = one skill domain. Split cross-domain work. |

---

## Claude Code Native Alignment

This spec's artifacts must be structurally compatible with Claude Code's native task and agent systems as they evolve.

### Tasks Alignment

| ADF Artifact | Claude Code Native | Alignment Status |
|-------------|-------------------|-----------------|
| tasks.md (task list with status) | Claude Code Tasks (persistent on-disk, DAG dependencies) | **Conceptually aligned.** Both use persistent file-based task state with dependency tracking. ADF uses markdown tables; Claude Code uses its internal format. Connector/adapter needed for interop. |
| tasks.md dependency column | Tasks DAG (Task 3 blocks on Tasks 1+2) | **Aligned.** Both model directed acyclic graphs. ADF `Depends` column maps to Claude Code task blocking. |
| Phase boundary protocol (/clear + re-read) | Context management (aggressive /clear, task state persists on disk) | **Aligned.** Both treat the plan as durable on-disk state and context as disposable. |
| Handoff block in tasks.md | Task state shared across sessions | **Aligned in concept.** Claude Code Tasks broadcast state updates across active sessions. ADF handoff block serves the same purpose for cross-session continuity. |

### Agent Teams Alignment

| ADF Concept | Claude Code Native | Alignment Status |
|-----------|-------------------|-----------------|
| Parallel work streams (Step 4) | Agent Teams (multiple Claude instances coordinating via shared task lists) | **Directly aligned.** Agent Teams are the execution mechanism for the parallelization strategy defined in the plan. |
| Agent assignment by skill set | Custom subagents (`.claude/agents/` with frontmatter: model, tools, system prompt) | **Directly aligned.** Each custom subagent = one agent type from the plan's assignment table. |
| Model tiering per stream | Subagent model configuration | **Aligned.** Custom subagents specify model tier in frontmatter config. |
| Capability registry | `.claude/agents/` + `.claude/commands/` + skills registry | **Partially aligned.** Claude Code has agent discovery but no formal capability registry with gap detection. ADF registry fills this gap. |
| Orchestrator-Workers pattern | Main session → subagents / Agent Teams | **Aligned.** Work Manager (or primary agent) acts as orchestrator; specialized subagents are workers. |

### Backlog: Native Integration

The following items are needed to close alignment gaps between ADF artifacts and Claude Code's native systems:

- **ADF-to-Tasks adapter:** Script or tool that converts tasks.md markdown tables into Claude Code's native task format, preserving dependencies
- **Subagent-to-registry sync:** Auto-populate capabilities registry from `.claude/agents/` and `.claude/commands/` definitions
- **Plan-to-Agent-Teams orchestration:** Given a plan.md parallelization strategy, generate the Claude Code commands to spin up the appropriate agent team configuration
- **Bidirectional status sync:** When Claude Code Tasks update status, reflect back to tasks.md (and eventually to Work OS)

---

## Enterprise Evolution Path

This spec is designed for a personal agentic harness. The patterns are chosen to scale to enterprise-class systems with minimal architectural changes.

### What Scales As-Is

| Pattern | Personal Use | Enterprise Evolution |
|---------|-------------|---------------------|
| Capability registry + gap detection | Local INVENTORY.md file | Centralized capability catalog service with API |
| Gap report → user interaction | Single human resolves gaps | Role-based routing: tech lead for skills, platform team for tools, procurement for licensed capabilities |
| Parallelization strategy | Multiple Claude Code sessions/subagents | Distributed agent fleet with load balancing and resource scheduling |
| Cross-cutting agent teams (validator, reviewer, improver) | Dispatched from personal agent pool | Shared services with SLAs, versioned configurations, audit trails |
| Plan → tasks → execution tracking | ADF markdown artifacts + Work OS | Enterprise project management with governance controls, compliance checkpoints |
| Model tiering | Cost optimization across personal budget | Enterprise model routing with cost centers, usage quotas, data classification controls |

### What Needs Enterprise Adaptation

| Concern | Current State | Enterprise Requirement |
|---------|--------------|----------------------|
| HITL routing | You (single human) | Multi-role approval workflows with delegation and escalation |
| Capability provisioning | Manual registry management | Self-service capability marketplace with approval workflows |
| Audit trail | Activity log in Postgres | Immutable audit ledger (DOLT/Datomic), compliance reporting |
| Multi-tenancy | Single user, single portfolio | Isolated workspaces per team/org with shared capability pools |
| Security boundaries | Docker sandboxing, allowlists | Zero-trust agent permissions, data classification enforcement, SOC 2 compliance |
| Cost governance | Personal budget awareness | Per-mission cost budgets, chargeback to cost centers, usage analytics |

### Design Principle

**Build for one, design for many.** Every pattern in this spec should work for a solo developer managing 10 projects with AI agents. But the interfaces (capability registry, gap reports, validation criteria, agent assignment) are shaped so that swapping the personal implementation for an enterprise service requires changing the *backend*, not the *architecture*.

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-09 | Initial specification |
