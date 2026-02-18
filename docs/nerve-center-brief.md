---
type: "concept-brief"
description: "Concept brief for the Nerve Center — a visual interface for the agentic work system that instantiates the Observability Ring as a human-readable medium."
version: "0.1.0"
updated: "2026-02-11"
scope: "system"
lifecycle: "superseded"
owner: "Jess"
status: "superseded"
superseded-by: ["nerve-center-product-brief.md", "nerve-center-architecture.md"]
backlog-refs: ["B4", "B21", "B9"]
---

> **SUPERSEDED:** This concept brief has been replaced by two documents in the Nerve Center project:
> - `~/code/_shared/nerve-center/docs/nerve-center-product-brief.md` — Product brief (what and why)
> - `~/code/_shared/nerve-center/docs/nerve-center-architecture.md` — Architecture spec (how)
>
> The Nerve Center is now its own ADF project at `~/code/_shared/nerve-center/`.
> Retained for historical reference.

# Nerve Center: Visual Interface for the Agentic Work System

## Problem

The agentic work system has seven active components (ADF, Knowledge Base, Memory, Capabilities Registry, Krypton, Link Triage, Work Management), each with their own project workspace, status files, health checks, and backlogs. The system's architecture defines four layers and five rings — but the **Observability Ring is the least built ring across all layers.**

Today, understanding system health requires:

- Reading 7+ status.md files manually
- Running `/krypton:kstatus` for a text-based cross-project snapshot
- Running `/adf-env:audit` per project for environment health
- Querying KB and Memory MCP servers for knowledge statistics
- Checking git logs across repositories for activity patterns
- Reviewing audit logs at `~/.krypton/audit/` for action trails

This is operationally expensive and cognitively fragmented. The human can't form a spatial, intuitive mental model of system state. And the architecture's governing principle — **"You can't increase autonomy for what you can't observe"** — means the system can't evolve until observation improves.

## Desired Outcome

A visual interface ("Nerve Center") that:

1. Gives the human a complete system health assessment in under 10 seconds
2. Enables spatial, visual pattern recognition that text interfaces can't provide
3. Makes the Observability Ring operational across all four layers
4. Provides the trust-building evidence needed for autonomy escalation
5. Reads from agent-native data sources — no separate data pipeline
6. Remains agent-first: agents don't need the UI, but can contribute to it

## Design Philosophy

### Agent-First, Human-Second

The UI is a **read-only viewport** onto data that agents already produce. It does not introduce new data flows, processing pipelines, or storage systems. Every data source it reads already exists:

| Source | Format | Already Exists At |
|--------|--------|-------------------|
| Project stage & health | Markdown (status.md) | Each project's docs/ |
| Knowledge entries | SQLite + Chroma | knowledge-base/data/ |
| Memory entries | SQLite + Chroma | memory/data/ |
| Capabilities catalog | YAML + JSON | capabilities-registry/ |
| Audit trail | JSONL | ~/.krypton/audit/ |
| Backlog items | Markdown | Each project's BACKLOG.md |
| ADF health checks | MCP tools | adf-server (live) |
| Git activity | Git log | Each project repo |

Agents remain the primary operators. The UI amplifies what humans uniquely contribute: spatial reasoning, anomaly detection, trend recognition, and intuitive pattern matching.

### The Cockpit, Not the Engine Room

Not everything agents see needs to be shown. The UI surfaces **signals**, not **data**. It optimizes for:

- **10-second assessment** — system health at a glance from any zoom level
- **Anomaly visibility** — problems glow, healthy systems fade to background
- **Spatial relationships** — see how components connect, where knowledge flows, what depends on what
- **Temporal patterns** — trends, velocity, staleness, activity rhythms

### Zoom Levels

The interface operates on a consistent zoom metaphor:

| Level | Name | What You See | When You Use It |
|-------|------|-------------|-----------------|
| **L0** | Orbit | Entire system, one screen, 10s assessment | Daily check-in, "is everything OK?" |
| **L1** | Domain | One subsystem in detail (projects, knowledge, capabilities, etc.) | Investigating a specific area |
| **L2** | Entity | Single item with full context and relationships | Focused work on one thing |
| **L3** | Data | Raw underlying data | Debugging, agent troubleshooting |

## Feature Areas

### L0 — Orbit View (System Pulse)

The home screen. Everything at a glance.

**Components:**

- **System heartbeat** — single composite health indicator (green/yellow/red) synthesized from all subsystems
- **Layer vitals** — four horizontal bands (Intent → Governance → Management → Operations) showing activity and health. Maps directly to the architecture's layer model.
- **Ring status** — five indicators (Governance, Intelligence, Knowledge, Control, Observability) showing ring health. Gaps pulse for attention.
- **Project constellation** — all active projects as spatial nodes. Size = activity. Color = ADF stage. Lines = dependencies/knowledge flows.
- **Activity pulse** — sparkline of system-wide activity (commits, KB writes, memory entries, stage transitions) over 7/30 days
- **Attention flags** — 0-3 items needing human attention now (stale projects, failed checks, governance drift, blocked work)

### L1 — Domain Views

Six domain views, each accessible from orbit:

**1. Project Pipeline**
ADF stages as a horizontal flow. Projects as cards within their stage. Hard gates as barriers. Each card shows health, days-in-stage, next action, blockers. Stale projects visually decay.

**2. Knowledge Topology**
KB entries as a force-directed graph. Nodes = entries, edges = shared topics. Clusters form around topic areas. Size = priority score. Focus topics highlighted. Orphans isolated. Time slider for growth animation.

**3. Memory Landscape**
Namespace bubbles (global, project-scoped, private) as map regions. Entries as points within regions. Color = type (observation, preference, decision, relationship, progress). Density heatmap. Confidence as opacity.

**4. Capability Observatory**
60 capabilities as a visual inventory. Grouped by type. Quality score as fill level. Source distinguished by color. Staging → Active pipeline. Usage mapping.

**5. Work Board**
Unified kanban across all projects. Swimlanes by project or priority tier. Cross-project items highlighted. Dependencies as connecting lines.

**6. Intelligence Feed**
Synthesized signals (not raw data). "Project X stalled for 14 days." "KB topic has entries but no synthesis." Each insight linked to source data and actionable (dismiss, investigate, create backlog item).

### Layers & Rings Matrix

The architecture's core model — interactive:

```
              Gov.  Intel.  Knowledge  Control  Observ.
Intent        [●]    [●]      [●]       [○]      [◐]
Governance    [◐]    [○]      [●]       [◐]      [○]
Management    [◐]    [○]      [●]       [●]      [◐]
Operations    [●]    [●]      [●]       [●]      [◐]
```

Each cell = instantiation status (full, partial, empty). Click any cell to see infrastructure, gaps, and related backlog items. This is the system's **maturity model made visible**.

### Autonomy Ratio Tracking

Four gauges showing current human-agent ratio per layer, with historical trend and target markers:

```
Intent:      [████████░░] 80/20  →  target: 60/40 (12mo)
Governance:  [█████░░░░░] 50/50  →  target: 30/70 (12mo)
Management:  [███░░░░░░░] 30/70  →  target: 15/85 (12mo)
Operations:  [█░░░░░░░░░] 10/90  →  target: 3/97  (12mo)
```

Tracks whether the system is evolving toward its design goals.

### Governance Health (Visual)

The weekly governance check from `architecture.md`, rendered visually:

| Check | Status | Trend | Detail |
|-------|--------|-------|--------|
| Priority alignment | Green | Stable | Execution matches stated strategy |
| Execution drift | Yellow | Worsening | 2 projects diverging from plan |
| Policy adherence | Green | Improving | All reviews using adf-review skill |
| Stale work | Red | 2 stalled | Link Triage, Work Management inactive 14d+ |
| Resource coherence | Yellow | Scattered | Attention spread across 5 projects |

## Agent Integration

The UI is read-only for humans, but agents can contribute:

**Notification bus** — agents post structured alerts that surface as attention flags:
```json
{
  "severity": "warning",
  "source": "adf-env-audit",
  "message": "CLAUDE.md exceeds 50 lines in project X",
  "action": "review-context"
}
```

**Dashboard as MCP resource** — aggregated health data exposed via MCP so agents querying system health get the same view the UI shows. Maintains agent-first parity.

**Human intent gestures** — lightweight UI interactions that inform agents without directing them:
- "This project needs attention" → priority signal adjustment
- "Pause this work" → flag for agent awareness
- "These are related" → knowledge link creation

## Technical Architecture

### Data Aggregation Layer

A thin local service that:
1. Watches file changes (status.md, BACKLOG.md, audit logs) via filesystem events
2. Reads SQLite databases (KB, Memory) on interval
3. Queries ADF health via MCP tools
4. Parses git logs for activity data
5. Computes derived metrics (velocity, staleness, drift indicators)
6. Serves unified API to the web frontend

This layer is the Observability Ring's implementation. It observes everything, computes nothing new, and makes system state visible.

### Recommended Stack

**Local web server + browser UI:**

- **Backend:** Python or Node.js local server
  - Direct SQLite reads (KB, Memory databases)
  - File watchers for markdown artifacts
  - Git log parsing
  - MCP client for live ADF health queries
  - REST/WebSocket API to frontend
- **Frontend:** React or Svelte
  - D3.js or similar for graph visualizations (knowledge topology, project constellation)
  - Standard charting for sparklines, gauges, timelines
  - Responsive grid layout for dashboard composition
- **No cloud dependency** — fully local, fully private
- **Optional:** Expose aggregation layer as MCP server (agents get the same aggregated view)

### Why This Stack

| Requirement | How It's Met |
|-------------|-------------|
| Agent-first (no new data flows) | Reads existing SQLite, files, MCP — no new storage |
| Visual richness for human cognition | Browser rendering with D3.js graphs, rich CSS |
| Local and private | No cloud, no auth, no network dependency |
| Extensible to agents | Backend can double as MCP server |
| Rapid iteration | Web tech allows fast UI experimentation |

## MVP Scope

### Phase 1: Orbit + Projects (Weeks 1-2)

Delivers the highest-value view — system health at a glance.

- System health composite indicator
- Project constellation (all projects, stages, health colors)
- Activity pulse sparkline (7/30 day)
- Attention flags (stale projects, failed checks)
- Click-to-expand project cards (status, stage, next action)
- Data sources: status.md files, git logs, ADF health checks

**Value:** Replaces reading 7+ status.md files. Immediate spatial understanding.

### Phase 2: Knowledge + Memory (Weeks 3-4)

- KB topology graph (force-directed, topic clusters)
- Memory landscape (namespace regions, type colors)
- Knowledge flow summary (capture → store → synthesize pipeline)
- Data sources: KB SQLite, Memory SQLite, Chroma metadata

**Value:** Visual exploration of accumulated knowledge. Gap identification.

### Phase 3: Capabilities + Work (Weeks 5-6)

- Capability observatory (visual inventory, quality scores)
- Unified work board (cross-project backlog items)
- Cross-project dependency web
- Data sources: capabilities YAML/JSON, BACKLOG.md files

**Value:** Full operational visibility across the system.

### Phase 4: Intelligence + Governance (Weeks 7-8)

- Layers & Rings matrix (interactive maturity model)
- Autonomy ratio gauges with trend tracking
- Governance health report (visual traffic lights)
- Intelligence feed (synthesized signals)
- Session timeline (unified activity view)
- Data sources: audit logs, all previous sources combined

**Value:** Governance and evolution tracking. The full Observability Ring.

## Success Criteria

1. **10-second rule:** Human can assess full system health in one screen view
2. **Zero new data flows:** All data read from existing agent-native sources
3. **Pattern discovery:** Human identifies at least one non-obvious pattern (stale project, knowledge gap, dependency risk) within the first week of use
4. **Agent parity:** Aggregated data available to agents via MCP (optional but valuable)
5. **Autonomy evidence:** Provides the observation foundation needed to justify shifting human-agent ratios

## What This Is Not

- Not a task management tool (agents manage tasks via CLI and MCP)
- Not a code editor or IDE (stays out of execution)
- Not a replacement for Krypton's text-based intelligence (complements it visually)
- Not a remote/cloud service (local only, personal scale)
- Not a control plane (read-heavy, write-light — human intent gestures only)

## Relationship to Architecture

This concept directly instantiates the **Observability Ring** from `architecture.md`. It addresses:

- **B4:** Cross-project observability — system-level dashboard
- **B9:** Autonomy escalation tracking — visual ratio evolution
- **B21:** Architecture diagrams — visual models at multiple levels

The architecture states: *"You can't increase autonomy for what you can't observe."* This project builds the observation infrastructure required for the system to evolve.

## Open Questions

| # | Question | Impact |
|---|----------|--------|
| 1 | Should the aggregation layer be a standalone MCP server? | Determines whether agents get the same aggregated view |
| 2 | How to handle real-time vs. polling for data freshness? | WebSocket for live updates vs. interval polling |
| 3 | Should the UI support multiple users (e.g., showing a collaborator the system)? | Scope: personal-only vs. shareable |
| 4 | What's the right balance of interactivity? Read-only vs. intent gestures? | Determines UI complexity and agent integration depth |
| 5 | Should there be a TUI companion for quick checks without leaving terminal? | Parallel lightweight interface |
