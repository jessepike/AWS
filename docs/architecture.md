---
type: "architecture"
description: "System-level architecture for agentic work — defines layers, rings, system boundaries, cross-cutting agent teams, and component relationships. The governing reference that ADF, Work Management, and Krypton all operate within."
version: "1.0.0"
updated: "2026-02-09"
scope: "system"
lifecycle: "reference"
owner: "Jess"
status: "draft"
---

# Agentic Work System Architecture

## Purpose

This document defines the **system-level architecture** for how agentic work gets organized, executed, governed, and improved across all domains — development projects, business operations, consulting, board work, and personal work.

It is the governing reference that sits above and connects the major subsystems:

| Subsystem | What It Does | Relationship to This Architecture |
|-----------|-------------|----------------------------------|
| **ADF** (Agentic Development Framework) | Defines how development projects move through stages | Operates within the Operations layer; uses the rings as support infrastructure |
| **Work Management** | Tracks and manages all work — state, flow, prioritization | Operates within the Management layer; provides the execution spine for all work types |
| **Krypton** | Personal AI chief of staff — cross-cutting intelligence and orchestration | Implements ring functions across all layers; provides strategic reasoning above Work Management |
| **Knowledge Base** | Curated learnings, patterns, best practices | Ring infrastructure — serves all layers |
| **Memory** | Session state, cross-agent continuity, history | Ring infrastructure — serves all layers |
| **Capabilities Registry** | Catalog of available skills, tools, agents | Ring infrastructure — serves all layers |

ADF and Work Management are **peers**, not parent-child. Both operate within this architecture. Work Management supports ADF-based development projects AND non-ADF work (business ops, consulting, board work, personal). ADF aligns with Work Management but does not depend on it, and Work Management does not live within ADF.

---

## Core Model: Layers and Rings

Two orthogonal structures compose the architecture:

**Layers** stack vertically — they represent **the work** at different altitudes. Intent flows down through decomposition. Reality flows back up as feedback. Each layer takes intent from above, decomposes it, passes it down, and returns outcomes back up.

**Rings** wrap horizontally around **every layer** — they represent **the support infrastructure** that enables each layer to function. Every layer gets the same rings, instantiated differently based on the layer's altitude and human-agent ratio.

```
                    LAYERS (vertical — the work)
                    ═══════════════════════════

    INTENT ──────────────────────────────────────────►
      │  "What and why"              ▲
      │  Human: 80 / Agent: 20      │
      ▼                              │
    GOVERNANCE ──────────────────────┤
      │  "Aligned?"                  │ Strategic drift,
      │  Human: 50 / Agent: 50      │ broken assumptions,
      ▼                              │ invalidated intent
    MANAGEMENT ──────────────────────┤
      │  "Organized and flowing?"    │ Operational reality,
      │  Human: 30 / Agent: 70      │ capacity signals,
      ▼                              │ blocker patterns
    OPERATIONS ──────────────────────┘
         "Done correctly?"
         Human: 10 / Agent: 90


                    RINGS (horizontal — support)
                    ═══════════════════════════

    ┌─────────────────────────────────────────┐
    │           GOVERNANCE RING                │
    │  Alignment, policy, constraints          │
    ├─────────────────────────────────────────┤
    │           INTELLIGENCE RING              │
    │  Reasoning, analysis, sensing            │
    ├─────────────────────────────────────────┤
    │           KNOWLEDGE RING                 │
    │  Memory, KB, instructions, context       │
    ├─────────────────────────────────────────┤
    │           CONTROL RING                   │
    │  Guardrails, rules, capabilities,        │
    │  permissions                             │
    ├─────────────────────────────────────────┤
    │           OBSERVABILITY RING             │
    │  Traceability, auditability,             │
    │  monitoring, feedback                    │
    └─────────────────────────────────────────┘
```

**The atomic primitive is intent.** Everything — from board-level vision down to a single task — has a purpose it's trying to fulfill. Layers decompose intent into progressively finer grain. Rings ensure each grain of intent is properly supported.

---

## Layers

### Layer 1: Intent

> *"What are we trying to achieve and why?"*

The highest layer. Sets vision, strategy, values, success criteria, and risk appetite. This is where the human is most cognitively engaged and agents serve as thinking partners.

| Attribute | Value |
|-----------|-------|
| **Function** | Vision, strategy, values, success criteria, risk appetite |
| **Intelligence type** | Strategic reasoning — pattern recognition across domains, long-term consequence modeling, second-order thinking |
| **Human-agent ratio** | 80/20 → Human cognition dominant, agents as thinking partners |
| **Agent role** | Synthesize, challenge assumptions, surface blind spots, research, stress-test logic |
| **Human role** | Final judgment, value alignment, commitment decisions |
| **Feedback receives** | Strategic drift signals from Governance, invalidated assumptions from Operations |
| **Traditional org analog** | Board of Directors + C-suite strategic sessions |
| **Current implementation** | Krypton in strategic mode (active — thinking partner sessions) |

### Layer 2: Governance

> *"Are we aligned with intent, and are the rules being followed?"*

The alignment engine. Sits between Intent and Operations, continuously asking "is what's happening what we intended?" Detects and surfaces drift. Recommends corrections. Escalates when assumptions break.

| Attribute | Value |
|-----------|-------|
| **Function** | Policy enforcement, alignment monitoring, risk management, resource allocation, course correction |
| **Intelligence type** | Analytical reasoning — gap detection, drift measurement, compliance validation, pattern matching against intent |
| **Human-agent ratio** | 50/50 → Shared cognition. Agents detect and surface. Humans judge and decide. |
| **Agent role** | Monitor alignment between intent and execution, flag drift, measure outcomes against criteria, recommend corrections |
| **Human role** | Approve corrections, escalate to Intent when assumptions break, set thresholds |
| **Feedback receives** | Operational metrics and anomalies from Operations, execution reality from Management |
| **Traditional org analog** | CEO + executive team ongoing governance, audit committee |
| **Current implementation** | Partially designed (Krypton's Autonomy Governor, Advisor role concept). Least built layer. |

### Layer 3: Management

> *"Is the work organized, prioritized, and flowing?"*

The operational coordination layer. Decomposes strategy into work streams, manages backlogs, detects blockers, optimizes sequencing, coordinates across domains and projects.

| Attribute | Value |
|-----------|-------|
| **Function** | Work decomposition, priority sequencing, resource coordination, blocker resolution, cross-functional alignment |
| **Intelligence type** | Operational reasoning — task decomposition, dependency mapping, priority optimization, bottleneck detection |
| **Human-agent ratio** | 30/70 → Agents do the bulk of organizing, sequencing, routing. Humans set goals and resolve ambiguity. |
| **Agent role** | Decompose strategy into work streams, manage backlogs, detect blockers, optimize sequencing, coordinate across domains |
| **Human role** | Set sprint-level goals, resolve competing priorities, make judgment calls on ambiguous tradeoffs |
| **Feedback receives** | Execution status from Operations, capacity signals from workers |
| **Traditional org analog** | VP/Director layer, project management, program management |
| **Current implementation** | Work Manager (designed, not built). Work OS (designed, brief v5). ADF Develop planning phases (operational). |

### Layer 4: Operations

> *"Is the work getting done correctly?"*

The execution layer. Where tasks get completed, workflows get processed, and outputs get produced. Most work here is deterministic or lightly reasoned. Intelligence is deployed for exceptions, edge cases, and quality validation.

| Attribute | Value |
|-----------|-------|
| **Function** | Task execution, workflow processing, deterministic automation, quality checks |
| **Intelligence type** | Tactical reasoning (where needed) — most work is deterministic. Intelligence for exceptions, edge cases, quality validation. |
| **Human-agent ratio** | 10/90 → Agents execute. Humans audit samples, handle escalations, validate edge cases. |
| **Agent role** | Execute tasks, run workflows, process data, generate outputs, flag exceptions |
| **Human role** | Spot-check quality, handle escalated exceptions, provide judgment on novel situations |
| **Feedback receives** | Task-level results, error rates, execution metrics |
| **Traditional org analog** | Individual contributors, process workers, automated systems |
| **Current implementation** | ADF stage agents (operational). Claude Code agents. Risk Brain agents (designed). |

### Layer Relationships

Intent flows down. Reality flows up. Each layer has contracts with adjacent layers — defined inputs it receives from above and defined outputs it emits below.

```
INTENT ──────────────────────────────────────►
  │  emits: vision, strategy, success          ▲
  │  criteria, risk appetite                   │
  ▼                                            │
GOVERNANCE ──────────────────────────────────┤
  │  emits: policies, constraints,             │ drift signals,
  │  alignment decisions, resource              │ broken assumptions,
  │  allocation                                │ invalidated intent
  ▼                                            │
MANAGEMENT ──────────────────────────────────┤
  │  emits: plans, tasks, priorities,          │ execution reality,
  │  assignments, schedules                    │ capacity signals,
  ▼                                            │ blocker patterns
OPERATIONS ──────────────────────────────────┘
     emits: completed work, outcomes,
     metrics, exceptions, learnings
```

### Human-Agent Ratio Evolution

The ratios are not static — they're the **autonomy escalation roadmap**. As trust builds at each layer, the ratio shifts toward more agent autonomy. Each layer has its own trust-building trajectory.

| Layer | Today | 6 Months | 12 Months | Condition for Shift |
|-------|-------|----------|-----------|---------------------|
| Intent | 80/20 | 70/30 | 60/40 | Krypton proves strategic judgment consistency |
| Governance | 50/50 | 40/60 | 30/70 | Drift detection accuracy validated; correction recommendations consistently good |
| Management | 30/70 | 20/80 | 15/85 | Work Manager proves reliable cross-project prioritization |
| Operations | 10/90 | 5/95 | 3/97 | Agent execution quality consistently meets acceptance criteria |

### Model Tier Mapping

The reasoning gradient maps to model selection. Heavier reasoning at higher layers, lighter at lower.

| Layer | Minimum Model Tier | Rationale |
|-------|-------------------|-----------|
| Intent | Opus | Strategic reasoning, pattern recognition across domains, long-term thinking |
| Governance | Sonnet/Opus | Analytical reasoning, drift detection, gap analysis |
| Management | Sonnet | Operational reasoning, decomposition, prioritization |
| Operations | Haiku/Sonnet | Tactical reasoning, deterministic execution, lightweight quality checks |

---

## Rings

Rings wrap horizontally around every layer. They're the universal support infrastructure. Each layer instantiates the same five rings differently based on its altitude and needs.

### Ring 1: Governance Ring

> *Alignment, policy, constraints*

Ensures every layer stays aligned with the intent that governs it. At the Intent layer, the Governance ring checks alignment with values and mission. At Operations, it checks alignment with task acceptance criteria.

| At Layer | What It Does |
|----------|-------------|
| Intent | Are we aligned with our values and mission? |
| Governance | Are policies consistent with intent? |
| Management | Are priorities aligned with strategy? Is work organized per governance policies? |
| Operations | Are tasks being executed within constraints? Do outputs match acceptance criteria? |

### Ring 2: Intelligence Ring

> *Reasoning, analysis, sensing*

Provides the cognitive capabilities each layer needs. Different intelligence types serve different layers — strategic reasoning at Intent, operational reasoning at Management, tactical reasoning at Operations.

| At Layer | What It Does |
|----------|-------------|
| Intent | Pattern recognition, second-order thinking, strategic analysis |
| Governance | Gap detection, drift measurement, compliance analysis |
| Management | Dependency mapping, priority optimization, bottleneck detection |
| Operations | Exception handling, edge case reasoning, quality assessment |

### Ring 3: Knowledge Ring

> *Memory, KB, instructions, context*

Provides the information infrastructure every layer needs. KB stores curated learnings. Memory stores session state and history. Instructions live with agents (CLAUDE.md, rules, prompts, skills). Context is loaded progressively based on need.

| At Layer | What It Does |
|----------|-------------|
| Intent | Strategic context, prior decisions, domain knowledge, market intelligence |
| Governance | Policy history, audit trails, compliance records, alignment baselines |
| Management | Project context, task history, capability inventory, cross-project patterns |
| Operations | Execution instructions, technical references, prior solutions, test patterns |

### Ring 4: Control Ring

> *Guardrails, rules, capabilities, permissions*

Defines what agents can and cannot do at each layer. Includes capabilities (what's available), permissions (what's allowed), and guardrails (what's prohibited).

| At Layer | What It Does |
|----------|-------------|
| Intent | What strategic tools are available? What decisions require human commitment? |
| Governance | What monitoring capabilities exist? What escalation thresholds are set? |
| Management | What planning and coordination tools are available? What requires approval? |
| Operations | What execution tools, skills, and agents are available? What's sandboxed? What's blocked? |

### Ring 5: Observability Ring

> *Traceability, auditability, monitoring, feedback*

Makes the system transparent and trustworthy. Every layer's work should be traceable, auditable, and monitorable. This ring is the evidence layer that enables autonomy escalation — you can't trust what you can't observe.

| At Layer | What It Does |
|----------|-------------|
| Intent | Are strategic decisions logged? Can we trace why we chose this direction? |
| Governance | Are alignment checks recorded? Can we audit governance decisions? |
| Management | Is work state tracked? Can we see what's planned, in-progress, blocked, complete? |
| Operations | Are task completions logged? Can we verify outputs? Activity trail? |

### Ring Instantiation Example

How the same rings apply differently at different layers — using the ADF Design stage as an example:

| Ring | Design Stage Instantiation |
|------|---------------------------|
| **Governance** | Is this design aligned with strategy? Does it meet architectural principles? |
| **Intelligence** | Reasoning about tradeoffs, alternatives, feasibility analysis |
| **Knowledge** | Prior designs, patterns, reference architectures, project context from KB |
| **Control** | What's in scope, what's out, what requires approval, capability constraints |
| **Observability** | Is the design progressing? Where is it stuck? Can we trace decisions? |

---

## System Boundaries

### The Three Peer Systems

```
┌──────────────────────────────────────────────────────────────┐
│                    KRYPTON                                     │
│           (Cross-cutting Intelligence)                        │
│                                                               │
│  Implements ring functions across all layers.                 │
│  Strategic reasoning. Proactive recommendations.              │
│  Queries Work Management and ADF for state.                   │
│  Does NOT direct agents — delegates to Work Manager.          │
│                                                               │
│  Knows: Everything — KB + Memory + Work State + Strategy +    │
│         Schedule + User Context                               │
│  Does: Reasons across all inputs, recommends priorities,      │
│        communicates proactively with human                    │
│  Talks to human: Proactively — "Here's what I think we       │
│                  should do next"                              │
│  Talks to Work Manager: Priority adjustments, strategic       │
│                         context, cross-domain signals         │
└──────────────────────────────────────────────────────────────┘
          │                              │
          │ queries/recommends           │ queries/recommends
          ▼                              ▼
┌─────────────────────────┐    ┌─────────────────────────┐
│    WORK MANAGEMENT      │    │         ADF             │
│   (Execution Spine)     │    │  (Dev Process Engine)   │
│                         │    │                         │
│  Tracks ALL work —      │◄──►│  Defines how dev        │
│  dev and non-dev.       │    │  projects move through  │
│  Manages backlogs,      │    │  stages.                │
│  plans, tasks, status.  │    │                         │
│  Directs agents.        │    │  ADF writes to Work     │
│  Validates completion.  │    │  Management via          │
│                         │    │  connector (tasks,       │
│  Knows: Backlogs, tasks,│    │  status, backlog).      │
│  status, plans across   │    │                         │
│  all projects           │    │  Work Management tracks │
│                         │    │  ADF project state      │
│  Does NOT need KB or    │    │  alongside non-ADF      │
│  Memory — that's        │    │  work.                  │
│  Krypton's job          │    │                         │
└─────────────────────────┘    └─────────────────────────┘
```

### Boundary Rules

| Function | Owner | Not |
|----------|-------|-----|
| Tracking work state (what exists, what's done) | Work Management | Krypton |
| Deciding what to work on (strategic prioritization) | Krypton + Human | Work Management alone |
| Directing agents to execute tasks | Work Management | Krypton |
| Understanding why work matters (strategic context) | Krypton | Work Management |
| How development projects progress through stages | ADF | Work Management |
| Validating quality of outputs | Cross-cutting agent teams | Any single system |
| Learning from completed work (improvement loop) | Cross-cutting agent teams + KB/Memory | Work Management |
| Routing work to agents | Work Management | Krypton |

### What Each System Accesses

| System | Accesses | Does NOT Access |
|--------|----------|-----------------|
| **Krypton** | Work Management state, KB, Memory, Calendar, all ring infrastructure | — (accesses everything) |
| **Work Management** | Backlogs, tasks, plans, status, activity logs, capabilities registry | KB, Memory (doesn't need them — that's Krypton's domain) |
| **ADF** | Its own specs/prompts/skills, capabilities registry, KB (via MCP) | Work Management directly (connects via adapter/connector) |

### Krypton vs. Work Manager — The Clean Split

| | Work Manager | Krypton |
|---|---|---|
| **Knows** | Backlogs, tasks, status, plans across all projects | Everything Work Manager knows + KB + Memory + Strategy + Schedule + User Context |
| **Does** | Tracks work state, directs agent tasks, maintains artifacts, ensures compliance | Reasons across all inputs, recommends priorities, communicates proactively with human |
| **Intelligence** | Operational — "is work happening as planned?" | Strategic — "what should we work on and why?" |
| **Talks to human** | Factually: "Here's the status" | Proactively: "Here's what I think we should do next" |
| **Talks to agents** | Directs them: "Do this task" | Doesn't direct agents — delegates to Work Manager |

If prioritization requires KB context or strategic reasoning, Krypton makes that determination and communicates it to Work Management as a priority adjustment. Work Management doesn't need to understand *why* — it needs to know *what's next*.

---

## Cross-Cutting Agent Teams

Three agent capabilities are pulled out of any single system into shared capability pools. They are dispatched to any layer, any system, any domain that needs them. They are not owned by Work Management or Krypton — they are shared services.

### Team Architecture

| Team | Core Function | Common Skills | Model Tier | Dispatched To |
|------|--------------|---------------|-----------|---------------|
| **Validation Team** | "Were these things done?" | State comparison, criteria checking, drift detection | Haiku (lightweight) | Work Management, ADF stages, Risk Brain, anywhere |
| **Review Team** | "Is this good?" | Quality assessment, gap analysis, YAGNI enforcement | Sonnet (moderate) | Design review, plan review, code review, anywhere |
| **Improvement Team** | "How do we get better?" | Pattern detection, efficiency analysis, KB/memory synthesis | Sonnet/Opus (higher reasoning) | Post-completion analysis, workflow optimization, anywhere |

### Dispatch Pattern

Teams don't belong to a domain. They receive domain-specific context at dispatch time.

```
Requesting System              Cross-Cutting Team
(e.g., Work Manager)          (e.g., Validation Team)
        │                              │
        │ REQUEST:                     │
        │ "Validate Phase 3            │
        │  completion for              │
        │  Project X"                  │
        │                              │
        │  + acceptance criteria       │
        │  + current task states       │
        │  + domain context            │
        │──────────────────────────►   │
        │                              │ EXECUTES:
        │                              │ - Reads criteria
        │                              │ - Checks states
        │                              │ - Produces report
        │                              │
        │   ◄──────────────────────────│
        │ RESPONSE:                    │
        │ "3/5 criteria met.           │
        │  2 gaps identified.          │
        │  Details attached."          │
```

### Validation Team

Completion checking — "were these things done?" Checks current state against target state. Used at phase boundaries, task completion, stage gates, and anywhere intent-to-actual alignment needs verification.

**Skills:** State comparison against acceptance criteria, drift detection (actual vs. intended), checklist verification, binary pass/fail assessment, gap identification and reporting.

**Does NOT:** Judge quality (that's Review). Suggest improvements (that's Improvement). Make strategic decisions.

**Dispatched by:** Work Manager (task/phase validation), ADF (stage gate checks), Krypton (strategic alignment checks).

### Review Team

Quality assessment — "is this good?" Provides second-set-of-eyes evaluation. Used for design review, plan review, code review, brief review — any artifact that benefits from quality evaluation.

**Skills:** Quality assessment against standards, gap analysis, YAGNI enforcement, consistency checking, best practice evaluation, constructive feedback generation.

**Does NOT:** Verify completion (that's Validation). Make execution decisions. Direct other agents.

**Dispatched by:** ADF (Ralph Loop reviews, external reviews), Work Manager (plan quality checks), Krypton (strategic document review).

### Improvement Team

Learning loop — "how do we get better?" Identifies improvement opportunities from patterns across memory, KB, status, and operational data. Produces improvement proposals.

**Skills:** Pattern detection across work history, efficiency analysis, workflow optimization recommendations, KB/memory synthesis, root cause analysis, improvement proposal generation.

**Does NOT:** Execute improvements (those become backlog items). Make priority decisions. Override existing processes.

**Dispatched by:** Krypton (periodic improvement sweeps), Work Manager (post-completion analysis), Human (explicit improvement requests).

**Output:** Improvement items are proposed as backlog entries with category "improvement" — they enter the normal work intake flow and compete for priority like any other work.

---

## How Components Map to the Architecture

### Layer Mapping

| Layer | Primary Systems | Current State |
|-------|----------------|---------------|
| Intent | Krypton (strategic mode), Human | Active — strategic thinking partner sessions |
| Governance | Krypton (Autonomy Governor) | Designed, not built. Least mature layer. Governance health check (see below) as minimal implementation. |
| Management | Work Manager, Krypton (operational intelligence) | Work OS brief v5. Work Manager designed. Krypton designed. |
| Operations | ADF agents, Claude Code, Risk Brain agents | ADF operational. Claude Code active. Risk Brain designed. |

### Ring Mapping

| Ring | Primary Infrastructure | Current State |
|------|----------------------|---------------|
| Governance | Krypton's alignment monitoring, ADF stage gates, rules (.claude/rules/) | Partially implemented via ADF rules and stage gates |
| Intelligence | Krypton's reasoning engine, agent model tier selection | Designed in Krypton brief, not built |
| Knowledge | KB (MCP server, operational), Memory (planned), agent instructions (CLAUDE.md, rules, prompts) | KB operational. Memory planned (B18-B19). Instructions operational. |
| Control | Capabilities registry, permission model, guardrails, sandboxing | Registry operational. Permissions partially implemented. |
| Observability | Activity logs, status artifacts, audit trails | Basic — status.md per project. No cross-project observability yet. |

### ADF Within the Architecture

ADF is a **process engine** that operates primarily within the **Operations layer**. It defines how development projects move through stages (Discover → Design → Develop → Deliver). ADF's six environment primitives map to the rings:

| ADF Primitive | System Ring |
|---------------|------------|
| Orchestration | Governance Ring (stage gates, policy) + Control Ring (workflow rules) |
| Capabilities | Control Ring (what's available) |
| Knowledge | Knowledge Ring |
| Memory | Knowledge Ring |
| Maintenance | Observability Ring (freshness, health) |
| Validation | Governance Ring (alignment checks) |

ADF connects to Work Management via a connector/adapter. Work Management tracks ADF project state (tasks, status, backlog) alongside non-ADF work. ADF does not depend on Work Management to function — it can operate independently. But when both are active, Work Management has cross-project visibility that ADF alone cannot provide.

### Work Management Within the Architecture

Work Management is the **execution spine** that operates primarily within the **Management layer**. It tracks all work — ADF and non-ADF — through the work lifecycle: Capture → Plan → Execute → Validate → Complete.

Work Management's internal hierarchy:

```
Portfolio (all work, filterable)
└── Project (one body of work)
    ├── Backlog (unpromoted work queue)
    └── Plan (approved implementation approach)
        └── Phase (milestone-level grouping, optional)
            └── Task (atomic unit of work)
```

Work Management's internal agent hierarchy:

| Agent | Responsibility |
|-------|---------------|
| **Work Manager** (top) | Owns execution spine. Cross-project state. Coordinates subordinate agents. Directs task execution. |
| **Planning Agent** | Decomposes intent into phases and tasks. Follows ADF-PLANNING-SPEC methodology. |
| **Backlog/Status Manager** | Maintains backlogs across projects. Ensures status artifacts stay current. |

Note: Validator, Reviewer, and Improver agents are NOT owned by Work Management — they are cross-cutting teams dispatched as needed.

### Krypton Within the Architecture

Krypton is the **cross-cutting intelligence layer** that implements ring functions across all layers. It is not a layer itself — it's the nervous system that wraps around the work.

Krypton's primary responsibilities by ring:

| Ring | What Krypton Does |
|------|-------------------|
| Governance | Monitors alignment between intent and execution across all projects |
| Intelligence | Provides strategic and operational reasoning, priority recommendations |
| Knowledge | Synthesizes KB + Memory + Work State into actionable intelligence |
| Control | Enforces autonomy boundaries via Autonomy Governor |
| Observability | Generates digests, surfaces patterns, reports status |

---

## Data and Storage Architecture

### Current Approach: Postgres with Activity Logging

Work state is stored in Supabase (Postgres). Every state change is logged to an `activity_events` table with timestamp, actor, entity, old_state, new_state. This provides write-ahead traceability.

**Design principles for future migration:**
- Never delete activity events
- Always include timestamps
- Always record actor (human or agent ID)
- Structure activity_events with enough fidelity to migrate to append-only ledger later

### Future Consideration: Immutable Ledger

A ledger database (DOLT, Datomic) would provide immutable history with time-travel queries. This is valuable for enterprise evolution but is Phase 2+ capability. The current Postgres + activity log approach is sufficient for validating the work management model. Migrate when operational history becomes strategic ("show me velocity before/after process change").

---

## Enterprise Evolution Path

**Design principle:** "Build for one, design for many." Every pattern works for a solo developer managing 10 projects with AI agents. But interfaces are shaped so swapping personal implementation for enterprise service requires changing the backend, not the architecture.

### What Scales As-Is

| Pattern | Personal Scale | Enterprise Scale |
|---------|---------------|-----------------|
| Capability registry + gap detection | Local INVENTORY.md | Centralized capability catalog service with API |
| Gap report → user interaction | Single human resolves gaps | Role-based routing (tech lead for skills, platform team for tools) |
| Parallelization strategy | Multiple Claude Code sessions/subagents | Distributed agent fleet with load balancing |
| Cross-cutting agent teams | Dispatched from personal pool | Shared services with SLAs, versioned configs, audit trails |
| Plan → tasks → execution tracking | ADF markdown + Work OS | Enterprise PM with governance controls, compliance checkpoints |
| Model tiering | Cost optimization across personal budget | Enterprise model routing with cost centers, usage quotas |

### What Needs Enterprise Adaptation

| Capability | Personal | Enterprise |
|-----------|----------|-----------|
| HITL routing | You (single human) | Multi-role approval workflows with delegation and escalation |
| Capability provisioning | Manual registry management | Self-service capability marketplace with approval workflows |
| Audit trail | Activity log in Postgres | Immutable audit ledger, compliance reporting |
| Multi-tenancy | Single user, single portfolio | Isolated workspaces per team/org with shared capability pools |
| Security boundaries | Docker sandboxing, allowlists | Zero-trust agent permissions, data classification enforcement |
| Cost governance | Personal budget awareness | Per-mission cost budgets, chargeback to cost centers |

---

## Anthropic-Aligned Patterns

The architecture aligns with Anthropic's recommended agentic patterns:

| Anthropic Pattern | Architecture Application |
|------------------|--------------------------|
| Orchestrator-Workers | Work Manager orchestrates. Worker agents execute. Cross-cutting teams provide quality functions. |
| Parallelization (Sectioning) | Planning spec Step 4 — explicit parallelization strategy with independent work streams. |
| Subagent isolation | Each parallel stream gets own agent context. Prevents context window exhaustion. |
| Task decomposition (DAG) | Dependency graph in planning. Phases encode DAG structure. |
| Explore, Plan, Code, Commit | ADF stages map: Discover=Explore, Design+Develop Planning=Plan, Build=Code, Deliver=Commit. |
| Context management | Phase boundaries trigger /clear + re-read. Plan persists on disk; context is disposable. |
| Model tiering | Explicit model tier assignment per layer and per agent team. |
| Skills & custom subagents | Capability assessment maps to Claude Code subagents and skills registry. |
| Agent Teams (Opus 4.6) | Multiple coordinating Claude instances map to parallelization strategy in planning spec. |

### Claude Code Native Alignment

| Architecture Concept | Claude Code Native | Alignment Status |
|---------------------|-------------------|------------------|
| tasks.md (task list with status) | Claude Code Tasks (persistent on-disk, DAG dependencies) | Conceptually aligned. Adapter needed for interop. |
| Phase boundary protocol (/clear + re-read) | Context management (aggressive /clear, task state persists) | Aligned. Both treat plan as durable, context as disposable. |
| Parallel work streams | Agent Teams (multiple Claude instances) | Directly aligned. Agent Teams execute parallelization strategy. |
| Agent assignment by skill set | Custom subagents (.claude/agents/) | Directly aligned. Each subagent = one agent type from plan. |
| Model tiering per stream | Subagent model configuration | Aligned. Custom subagents specify model tier in frontmatter. |
| Capability registry | .claude/agents/ + .claude/commands/ + skills registry | Partially aligned. Claude Code lacks formal gap detection. ADF registry fills gap. |

---

## Design Principles

1. **Layers are the work. Rings are the support.** Don't conflate them. Layers decompose intent vertically. Rings provide horizontal infrastructure.

2. **Every entity has intent.** From board-level vision to a single task — each has a purpose it's fulfilling. Intent is the atomic primitive.

3. **Composability is first-class.** Each layer has input/output contracts with adjacent layers. Systems are peers with clean interfaces, not monoliths.

4. **Human-agent ratios are gradients, not gates.** HITL is not binary. It's a sliding ratio that varies by layer and evolves over time as trust builds.

5. **Build for one, design for many.** Every pattern works for solo use. Interfaces are shaped for enterprise substitution without architectural change.

6. **Cross-cutting capabilities are shared services.** Validation, review, and improvement are dispatched — not owned by any single system.

7. **The plan is durable. Context is disposable.** Artifacts on disk are the source of truth. Agent context windows are ephemeral and rebuilt from artifacts.

8. **Observation enables trust.** You can't increase autonomy for what you can't observe. The Observability ring is the prerequisite for autonomy escalation.

---

## Open Questions

| # | Question | Context | Status |
|---|----------|---------|--------|
| 1 | Governance-of-governance | Who audits the Governance layer? | **Resolved (minimal).** Krypton runs periodic governance health checks (see below). Human handles strategic governance review for now. Evolve as trust builds. |
| 2 | Human Harness ring | Do human insertion points deserve their own ring? | **Deferred.** Distributed across Governance (approval) and Intelligence (thinking support) for now. |
| 3 | Communication infrastructure | How information flows between systems and layers. | **Reframed as bus, not ring.** Communication is integration infrastructure (message formats, protocols, event routing), not a support ring. Define as part of interfaces section when building inter-system connectivity. |
| 4 | Resources/Capacity | Capacity, cost, and allocation tracking. | Open — may be a Management layer function rather than a ring. Revisit when portfolio roll-up and capacity planning become active. |
| 5 | Learning formalization | How the system improves over time. | Open — currently covered by Improvement Team + KB. Revisit when improvement workflow is operational and patterns emerge. |

---

## Governance Health Check (Minimal Implementation)

The governance-of-governance problem: who ensures the Governance layer itself is functioning? For now, the human handles strategic governance review. But a minimal automated check provides a foundation to evolve from.

**Implementation: Krypton Governance Health Check**

A lightweight, periodic alignment check that Krypton runs against Intent-layer artifacts. Not a new agent — Krypton already has the cross-cutting context. This is a structured skill with a cadence.

**What it checks:**

| Check | Question | Source |
|-------|----------|--------|
| Priority alignment | Are current project priorities consistent with stated strategy? | Work Manager state vs. intent.md / strategy artifacts |
| Drift detection | Has execution diverged from what we said we'd do? | Task completion patterns vs. plan artifacts |
| Governance policy adherence | Are governance policies being followed? (review cycles, validation gates, etc.) | ADF stage gate compliance, review logs |
| Stale work detection | Are any projects stalled without explicit decision to pause? | Status artifacts, last-updated timestamps |
| Resource allocation coherence | Is time/attention distributed consistent with stated priorities? | Activity patterns vs. priority ranking |

**Cadence:** Weekly. Produces a brief governance report. Flags anything that needs human attention. No autonomous corrections — recommendations only.

**Output format:** Short report with traffic light indicators (green/yellow/red) per check area, plus specific flags requiring human review.

**Evolution path:**
- Phase 1 (now): Manual Krypton skill. Human reviews weekly report.
- Phase 2 (trust builds): Krypton runs check automatically via heartbeat. Only surfaces yellow/red items.
- Phase 3 (high trust): Krypton makes minor governance corrections autonomously (e.g., flagging stale projects, adjusting priorities within pre-approved bounds). Major corrections still require human approval.

---

## Related Documents

| Document | Relationship |
|----------|-------------|
| ADF-ARCHITECTURE-SPEC.md | ADF's internal architecture. Operates within this system architecture. |
| ADF-PLANNING-SPEC.md | Planning methodology specification. Cross-cutting, used by Management layer. |
| ADF-DEVELOP-SPEC.md | Development stage specification. Operations layer process. |
| Work OS Brief v5 | Work Management data model and API. Management layer execution spine. |
| Krypton Platform Brief v1 | Personal AI chief of staff. Cross-cutting intelligence implementation. |
| Risk Brain v4 | AI risk management platform. Operations layer domain system. |
| ADF-TAXONOMY.md | Terminology reference. |

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-09 | Initial — layers-and-rings model, system boundaries, cross-cutting agent teams, component mapping, enterprise evolution path, Anthropic alignment, Claude Code native alignment |
