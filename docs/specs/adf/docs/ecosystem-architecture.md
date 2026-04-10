---
type: "architecture"
description: "Macro view of the full ecosystem — all systems, their roles, integration points, and build dependencies"
version: "0.1.0"
updated: "2026-02-07"
status: "draft"
lifecycle: "reference"
---

# Ecosystem Architecture

## Purpose

This document captures the **macro view** — how all systems in the ecosystem relate to each other, what each owns, how data flows between them, and in what order they get built.

The ADF Architecture Spec (ADF-ARCHITECTURE-SPEC.md) defines how ADF works internally. This document defines how ADF sits within a broader ecosystem of systems that together form a personal AI operating platform.

---

## The Three-Layer Model

The ecosystem is organized into three functional layers, each with a distinct responsibility:

```
┌─────────────────────────────────────────────────────────────────┐
│                    INTELLIGENCE LAYER                            │
│                                                                  │
│    Krypton (AI Chief of Staff)                    [concept]      │
│    Reasoning, interaction, autonomy, channels                    │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                       DATA LAYER                                 │
│                                                                  │
│    Work OS (Operational State)                    [concept]      │
│    Projects, tasks, backlogs, digests, dashboard                 │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                     PROCESS LAYER                                │
│                                                                  │
│    ADF (Agentic Development Framework)            [built]        │
│    Stages, specs, orchestration, governance                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | System | Owns | Question It Answers |
|-------|--------|------|---------------------|
| **Process** | ADF | How work gets done — stages, specs, review, governance | "What's the process?" |
| **Data** | Work OS | What work exists — projects, tasks, status, history | "What's the state of things?" |
| **Intelligence** | Krypton | Why and when — reasoning, prioritization, proactive action | "What should I do next?" |

### Key Principle

Each layer is **architecturally independent**. ADF doesn't require Work OS to function. Work OS doesn't require Krypton. But each layer amplifies the one below it — Work OS makes ADF's project state queryable across domains, and Krypton makes Work OS's data actionable through reasoning and proactive communication.

---

## System Map

Every system in the ecosystem, what it does, and where it lives.

### Platform Systems

| System | Role | Status | Location | Brief |
|--------|------|--------|----------|-------|
| **ADF** | Process framework — stages, specs, orchestration, governance | Built | `~/code/_shared/adf/` | ADF-ARCHITECTURE-SPEC.md |
| **Work OS** | Operational data layer — projects, tasks, backlogs, digests, dashboard | Concept | — | docs/inbox/work_os_brief_v5.md |
| **Krypton** | AI chief-of-staff — reasoning, channels, autonomy, intelligence | Concept | — | docs/inbox/krypton_platform_brief_v1.md |

### Shared Services

These are standalone systems consumed by multiple platform layers. They are not owned by any single layer — they serve the ecosystem.

| System | Role | Status | Location | Consumers |
|--------|------|--------|----------|-----------|
| **Knowledge Base** | Reference knowledge — learnings, ideas, notes, research | Built | `~/code/_shared/knowledge-base/` | ADF agents, Krypton (future) |
| **Memory Layer** | Contextual knowledge — decisions, preferences, patterns, session history | Built | `~/code/_shared/memory/` | ADF agents, Krypton (future) |
| **Capabilities Registry** | Catalog of available skills, tools, agents, plugins | Built | `~/code/_shared/capabilities-registry/` | ADF agents, Krypton (future) |
| **Link Triage Pipeline** | Content ingestion — URL capture, extraction, routing to KB | Built | `~/code/_shared/link-triage-pipeline/` | KB (target), Krypton (future trigger) |

### ADF Runtime Components

These implement ADF's framework and are tightly coupled to its specs. They live inside the ADF ecosystem but are registered in the capabilities registry for discoverability.

| Component | Type | Status | Location |
|-----------|------|--------|----------|
| **ADF MCP Server** | Tool (MCP) | Built | `~/code/_shared/adf/adf-server/` |
| **adf-env** | Plugin | Built | `~/.claude/plugins/adf-plugins/plugins/adf-env/` |
| **adf-review** | Plugin + Skill | Built | `~/.claude/plugins/adf-plugins/plugins/adf-review/` |
| **kb-manager** | Plugin | Built | `~/.claude/plugins/adf-plugins/plugins/kb-manager/` |

---

## Integration Map

How systems connect to each other and what flows between them.

```
                          ┌─────────────┐
                          │   Krypton   │
                          │(intelligence│
                          │  + channels)│
                          └──────┬──────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                   │
              ▼                  ▼                   ▼
     ┌────────────────┐  ┌────────────┐    ┌──────────────┐
     │    Work OS     │  │     KB     │    │    Memory    │
     │  (data layer)  │  │ (reference │    │ (contextual  │
     │                │  │  knowledge)│    │  knowledge)  │
     └───────┬────────┘  └─────┬──────┘    └──────┬───────┘
             │                 │                   │
             │                 │                   │
     ┌───────┴────────┐       │                   │
     │  ADF Connector │       │                   │
     │  (markdown     │       │                   │
     │   sync)        │       │                   │
     └───────┬────────┘       │                   │
             │                 │                   │
             ▼                 ▼                   ▼
     ┌─────────────────────────────────────────────────────┐
     │                        ADF                           │
     │        (process layer — specs, stages, governance)   │
     │                                                      │
     │   ┌──────────────┐  ┌────────────────────────────┐  │
     │   │ Capabilities │  │ Link Triage Pipeline       │  │
     │   │ Registry     │  │ (capture → extract → KB)   │  │
     │   └──────────────┘  └────────────────────────────┘  │
     └─────────────────────────────────────────────────────┘
```

### Integration Points

| From | To | Mechanism | Data Flow | Status |
|------|----|-----------|-----------|--------|
| ADF projects | Work OS | ADF Connector (markdown sync) | status.md, tasks.md, backlog.md → Work OS entities | Concept |
| Work OS | Krypton | Work OS MCP Skill | REST API queries → Krypton reasoning context | Concept |
| KB | Krypton | KB MCP Skill | Semantic search → Krypton context | Concept (KB built, integration planned) |
| KB | ADF agents | KB MCP Server | Search queries during project work | Built |
| Memory | Krypton | Memory MCP Skill | Cross-project context, preferences, history | Concept |
| Memory | ADF agents | Memory MCP Server | Session continuity, project-scoped recall | Planned (B18-B19) |
| Capabilities Registry | ADF agents | ADF MCP Server | Capability queries during Develop stage | Built |
| Link Triage | KB | Pipeline output | Extracted content → KB entries | Built |
| Krypton | Krypton channels | Channel adapters | Unified message format → platform-native | Concept |
| ADF agents | Memory | Write path | Session logs, decisions, observations | Planned |
| Memory | KB | Distillation | Raw memory → curated knowledge entries | Planned |

---

## Data Flow Patterns

### Pattern 1: Project State Aggregation (ADF → Work OS)

ADF projects produce structured artifacts (status.md, tasks.md, backlog.md). The ADF Connector parses these into Work OS entities, making project state queryable across the full portfolio regardless of where the project lives.

```
Dev project repo          Work OS               Krypton
  status.md ──parse──→ Project entity ──query──→ "Project X is blocked on auth"
  tasks.md  ──parse──→ Task entities  ──query──→ "3 tasks overdue this week"
  backlog.md ─parse──→ Backlog items  ──query──→ "Promote P1 backlog item?"
```

### Pattern 2: Knowledge Flow (Capture → Distill → Apply)

Raw experience captured during project work flows through stages of refinement into reusable knowledge.

```
Agent session                Memory              KB
  decision made ──capture──→ stored fact ──distill──→ curated learning
  friction hit  ──capture──→ observation ──distill──→ validated pattern
  preference    ──capture──→ preference  ────────────→ (stays in memory)
```

### Pattern 3: Intelligence Loop (Krypton)

Krypton queries multiple data sources, reasons across them, and delivers actionable output.

```
Work OS ──(project state)──→ ┌──────────┐ ──→ Daily digest
KB      ──(knowledge)──────→ │ Krypton  │ ──→ Priority recommendations
Memory  ──(context)────────→ │ (reason) │ ──→ Blocker alerts
Calendar ─(time)───────────→ └──────────┘ ──→ Proactive actions
```

---

## Dependency Chain and Build Order

The systems have a clear build dependency. Each layer requires the one below it to exist, but can be built incrementally.

```
Phase 1 (foundation)     Phase 2 (data)        Phase 3 (intelligence)
━━━━━━━━━━━━━━━━━━━     ━━━━━━━━━━━━━━━━     ━━━━━━━━━━━━━━━━━━━━━

ADF ✅                   Work OS               Krypton
  specs ✅                 schema                gateway
  adf-server ✅            REST API              first channel + skill
  adf-env ✅               MCP adapter           memory integration
  adf-review ✅            ADF connector         heartbeat/cron
                           digest engine          intelligence (basic)
KB ✅                      dashboard              additional channels
                                                  autonomy escalation
Capabilities Registry ✅  Memory Layer
                            schema + MCP
Link Triage ✅              scoping model
                            writer integration
```

### Critical Path

**Work OS is the critical path to Krypton.** Krypton's most important skill is Work OS — without operational data to reason over, Krypton's intelligence engine has nothing to work with.

**Memory Layer is parallel work.** It doesn't block Work OS or Krypton MVP, but enriches both. ADF agents benefit immediately from session persistence. Krypton benefits later from cross-project context.

### Build Dependencies

| System | Depends On | Blocks |
|--------|-----------|--------|
| ADF | — | Work OS (connector contract), Memory (writer integration) |
| KB | — | Krypton (knowledge skill) |
| Capabilities Registry | — | — (consumed, not blocking) |
| Link Triage | KB (target) | — |
| Memory Layer | — | Krypton (full context), ADF self-improvement loop |
| Work OS | ADF specs (connector contract) | Krypton (primary skill) |
| Krypton | Work OS (data), KB (knowledge), Memory (context) | — |

---

## Current State Summary

| System | Stage | What Exists | What's Next |
|--------|-------|-------------|-------------|
| **ADF** | Develop | 20+ specs, MCP server, plugins (adf-env, adf-review, kb-manager), skills, stubs, KB | Memory layer spec (B18-B19), status.md pruning |
| **KB** | Operational | SQLite + Chroma + MCP server, kb-manager plugin, search/CRUD tools | Krypton integration (future) |
| **Capabilities Registry** | Operational | 48 entries, inventory.json, staging/promotion workflow, INVENTORY.md | Ongoing curation |
| **Link Triage** | Operational | Python pipeline, config-driven, KB integration, URL dedup | Maintenance mode |
| **Memory Layer** | Research complete | Research synthesis doc, architecture recommendations, open design questions | Schema design, MCP tool surface, prototype |
| **Work OS** | Concept | Product brief v5 (entities, API, connectors, dashboard, digests) | ADF Discover/Design stages, then build |
| **Krypton** | Concept | Platform brief v1 (architecture, channels, skills, autonomy, intelligence) | Blocked by Work OS; parallel design possible |

---

## Relationship to ADF Architecture Spec

This document and ADF-ARCHITECTURE-SPEC.md are complementary:

| | ADF Architecture Spec | Ecosystem Architecture |
|---|---|---|
| **Scope** | ADF internals | Full ecosystem |
| **Focus** | How ADF works (stages, primitives, interfaces) | How all systems relate |
| **Audience** | Agent working within ADF | Human understanding the whole platform |
| **Updates when** | ADF framework changes | New systems added, integrations change |

The six ADF environment primitives (Orchestration, Capabilities, Knowledge, Memory, Maintenance, Validation) map to ecosystem-level concerns:

| ADF Primitive | Ecosystem Implementation |
|---------------|--------------------------|
| Orchestration | ADF specs + prompts + MCP server |
| Capabilities | Capabilities Registry (standalone repo) |
| Knowledge | KB (standalone MCP server) + ADF kb/ (process learnings) |
| Memory | Memory Layer (planned standalone repo + MCP server) |
| Maintenance | Distributed (each component self-maintains) |
| Validation | Distributed (adf-env audit, review skills, health checks) |

Work OS and Krypton extend *beyond* ADF's environment layer — they are products that consume ADF's services while also serving domains ADF doesn't cover (business projects, personal tasks, multi-channel communication, portfolio intelligence).

---

## Open Questions

| # | Question | Context |
|---|----------|---------|
| 1 | Should Work OS and Krypton follow ADF stages for their own development? | They're the most complex projects in the ecosystem — ADF eating its own dogfood |
| 2 | Does Krypton subsume ADF's orchestration role long-term? | Krypton's skill router + autonomy governor could eventually orchestrate stage workflows |
| 3 | Where does the memory layer live organizationally? | ADF primitive vs. standalone shared service — architecture spec says `~/code/_shared/memory/` |
| 4 | Should this document live in ADF or at a higher level? | It describes the ecosystem, not just ADF — but ADF is the natural home for now |
| 5 | How do non-dev projects (Papa Dogs, TCDC, consulting) enter the ecosystem before Work OS exists? | Currently invisible to the system — no structured state until Work OS is built |

---

## References

- ADF-ARCHITECTURE-SPEC.md — ADF internal architecture (six primitives, two-layer model)
- docs/inbox/work_os_brief_v5.md — Work OS product brief
- docs/inbox/krypton_platform_brief_v1.md — Krypton platform brief
- docs/inbox/memory-layer-research.md — Memory layer research synthesis
- docs/intent.md — ADF north star
