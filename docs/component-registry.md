# Component Registry

> The index of what each component is, what it owns, and where it sits.
>
> **Companions:** [architecture.md](architecture.md) (the model) · [communication-protocols.md](communication-protocols.md) (the connections)

---

## System Hierarchy

```
┌─────────────────────────────────────────────────────┐
│                  FRAMEWORK LAYER                     │
│                                                      │
│   ┌─────────────┐          ┌──────────────────┐     │
│   │     ADF      │─────────▶│ Work Management  │     │
│   │ (process     │  sync    │ (execution       │     │
│   │  engine)     │          │  spine)           │     │
│   └─────────────┘          └──────────────────┘     │
│                                                      │
├─────────────────────────────────────────────────────┤
│                INTELLIGENCE LAYER                    │
│                                                      │
│   ┌─────────────────────────────────────────────┐   │
│   │              Krypton                         │   │
│   │     (cross-cutting synthesis & routing)      │   │
│   └─────────────────────────────────────────────┘   │
│                                                      │
├─────────────────────────────────────────────────────┤
│               INFRASTRUCTURE LAYER                   │
│                                                      │
│   ┌──────────┐ ┌────────┐ ┌────────────┐ ┌───────┐ │
│   │Knowledge │ │Memory  │ │Capabilities│ │ Link  │ │
│   │  Base    │ │        │ │ Registry   │ │Triage │ │
│   └──────────┘ └────────┘ └────────────┘ └───────┘ │
└─────────────────────────────────────────────────────┘
```

---

## Component Cards

### ADF (Agentic Development Framework)

| | |
|---|---|
| **Purpose** | Process engine that defines how dev projects move through stages |
| **Owns** | Stage pipeline (Discover → Design → Develop → Deliver), artifact formats, review process (Ralph Loop + external), project type classification, six environment primitives |
| **Does not own** | Work tracking (→ Work Management), knowledge storage (→ KB), cross-project synthesis (→ Krypton) |
| **Stage** | Operate & Evolve — High maturity |
| **Primary interface** | MCP server (stdio, Node.js) — 16 tools |
| **Key artifacts** | ADF-ARCHITECTURE-SPEC.md, stage specs, planning spec, review spec, rules spec |
| **Location** | `~/code/_shared/adf/` |

### Work Management

| | |
|---|---|
| **Purpose** | System of record for all work — tracks projects, plans, phases, tasks, backlog, activity |
| **Owns** | Work entity model (Portfolio → Project → Plan → Phase → Task + Backlog), work lifecycle, health computation, activity logging, ADF connector |
| **Does not own** | Dev process rules (→ ADF), priority reasoning (→ Krypton + Human), knowledge/memory storage |
| **Stage** | Develop — Low maturity (schema done, API built, dashboard read-only, task CRUD not wired) |
| **Primary interface** | REST API (25 endpoints) + MCP server (stdio, Node.js, 40+ tools) |
| **Key artifacts** | Supabase schema (8 tables), Next.js dashboard (5 views), ADF parser/sync |
| **Location** | `~/code/_shared/work-management/` |

### Krypton

| | |
|---|---|
| **Purpose** | Personal AI chief of staff — cross-system intelligence, synthesis, and capture routing |
| **Owns** | Cross-system synthesis, priority recommendations, capture routing (KB vs Memory vs Work Mgmt), autonomy governance (hooks), audit logging with redaction |
| **Does not own** | Work tracking (→ Work Management), process rules (→ ADF), knowledge storage (→ KB), memory storage (→ Memory) |
| **Stage** | Operate & Evolve — Low maturity (v0.1.0, still learning how to leverage all components) |
| **Primary interface** | Claude Code plugin — 4 commands (`/focus`, `/digest`, `/capture`, `/kstatus`), 3 gatherer agents, 2 hooks |
| **Key artifacts** | Gatherer agents (kb, adf, memory), autonomy-gate hook, audit-log hook, redaction library |
| **Open questions** | What does the redaction library do? Should there be a Work Mgmt gatherer? Hook firing frequency/overhead? |
| **Location** | `~/code/_shared/krypton/` |

### Knowledge Base

| | |
|---|---|
| **Purpose** | Curated store of learnings, patterns, best practices with semantic search |
| **Owns** | 4-layer architecture (Capture → Process → Store → Access), content classification, priority scoring with focus topics, deduplication, maintenance |
| **Does not own** | Session/preference memory (→ Memory), capture routing decisions (→ Krypton), work items (→ Work Management) |
| **Stage** | Operate & Evolve — High maturity |
| **Primary interface** | MCP server (stdio, Python) — 16 tools |
| **Key artifacts** | SQLite + Chroma storage, OpenAI ada-002 embeddings, kb-manager plugin |
| **Open questions** | What role does kb-manager plugin play if main interface is MCP server? |
| **Location** | `~/code/_shared/knowledge-base/` |

### Memory

| | |
|---|---|
| **Purpose** | Persistent cross-session memory for agent workflows — preferences, decisions, observations |
| **Owns** | Memory types (observation, preference, decision, progress, relationship), namespace scoping, write-time consolidation, visibility controls |
| **Does not own** | Curated knowledge (→ KB), work state (→ Work Management), routing decisions (→ Krypton) |
| **Stage** | Operate & Evolve — Low maturity (operational but new, still understanding routing patterns) |
| **Primary interface** | MCP server (stdio, Python) — 15 tools |
| **Key artifacts** | SQLite + Chroma storage, local embeddings (sentence-transformers), routing heuristic doc |
| **Location** | `~/code/_shared/memory/` |

### Capabilities Registry

| | |
|---|---|
| **Purpose** | Curated personal catalog of skills, tools, agents, and plugins |
| **Owns** | Capability inventory, lifecycle (staging → active → archive), gap detection, MCP installers, freshness tracking |
| **Does not own** | Capability execution (→ each tool/plugin itself), work assignment (→ Work Management) |
| **Stage** | Operate & Evolve — Low maturity (operational but underutilized) |
| **Primary interface** | File-based (`INVENTORY.md`, `inventory.json`) + embedded in ADF MCP (`query_capabilities`, `get_capability_detail`) |
| **Key artifacts** | `capability.yaml` per capability, `declined.yaml`, sync/promote/generate-inventory scripts |
| **Location** | `~/code/_shared/capabilities-registry/` |

### Link Triage

| | |
|---|---|
| **Purpose** | Automated link processing pipeline — front-end funnel for knowledge capture |
| **Owns** | 8-step processing flow, LLM-powered classification, smart routing to Raindrop, content extraction, dedup, digest generation |
| **Does not own** | Knowledge storage (→ KB), capture routing policy (→ Krypton, planned), long-term memory (→ Memory) |
| **Stage** | Operate & Evolve — Low maturity (only operational ~1 week) |
| **Primary interface** | CLI (`python -m link_triage run`) |
| **Key artifacts** | Two-dimensional taxonomy (content type × action state), Raindrop integration, SQLite tracking DB, 160 tests / 95% coverage |
| **Location** | `~/code/_shared/link-triage-pipeline/` |

---

## Boundary Rules

| Question | Owner | Notes |
|----------|-------|-------|
| Who stores curated learnings? | Knowledge Base | Patterns, references, best practices |
| Who stores preferences & observations? | Memory | Cross-session agent memory |
| Who tracks work state? | Work Management | Projects, tasks, backlog, activity |
| Who decides priorities? | Krypton + Human | Krypton advises, human decides |
| Who defines dev process? | ADF | Stages, artifacts, reviews |
| Who routes captures? | Krypton | KB vs Memory vs Work Mgmt |
| Who directs agents? | Work Management | Task assignment and sequencing |
| Who explains *why* work matters? | Krypton | Cross-system context synthesis |
| Who catalogs available tools? | Capabilities Registry | Skills, plugins, agents, MCP servers |
| Who ingests links? | Link Triage | Classifies, routes to Raindrop + KB |
| Who validates quality? | Cross-cutting agent teams | Not owned by any single component |
| Who governs autonomy? | Krypton (hooks) | PreToolUse/PostToolUse gating |

---

## Maturity Overview

| Component | Stage | Built | Designed but not built | Gap |
|-----------|-------|-------|----------------------|-----|
| **ADF** | Operate & Evolve | MCP (16 tools), stage specs, plugins, Ralph Loop, external review | — | — |
| **Knowledge Base** | Operate & Evolve | MCP (16 tools), SQLite+Chroma, kb-manager plugin, bulk import | — | — |
| **Memory** | Operate & Evolve (Low) | MCP (15 tools), SQLite+Chroma, local embeddings, consolidation | — | Cross-query with KB (low priority), routing clarity |
| **Krypton** | Operate & Evolve (Low) | 4 commands, 3 gatherers, 2 hooks, redaction, 27+4 tests | Governance health check (B2), expanded capture routing (B3), WM gatherer | Work Mgmt integration, hook overhead review |
| **Capabilities Registry** | Operate & Evolve (Low) | INVENTORY.md, scripts, MCP installers, freshness tracking | — | No standalone MCP server, underutilized |
| **Link Triage** | Operate & Evolve (Low) | Pipeline, classification, Raindrop integration, KB capture, 160 tests | Krypton routing integration (B3) | Only ~1 week operational |
| **Work Management** | Develop | Supabase schema, REST API (25 endpoints), MCP (40+ tools), dashboard (5 views), ADF sync | Task CRUD in dashboard, event-driven ADF sync | Full Krypton integration |
