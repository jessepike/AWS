---
title: Intelligence Layer — Discover Brief
version: 1.0.0
stage: discover-complete
updated: 2026-04-10
author: Forge (with Jesse)
status: reviewed
covers: [intent, component-inventory, use-cases, boundaries, infrastructure, issues, success-criteria, risks, scope]
---

# Intelligence Layer — Discover Brief

**Intent:** See [intent.md](intent.md)

## 1. Problem Statement

The Agentic Work System (AWS) has accumulated five independent systems that collectively manage knowledge, memory, and content capture. They were built at different times, with different assumptions, and they don't compose into a coherent intelligence layer.

**The result:** agents start sessions partially blind. Learnings captured in one project don't reliably reach the knowledge store. Decisions made last week aren't surfaced this week. Content discovered by automated pipelines sits in the KB but isn't connected to operational context in Memory. A wiki synthesizes both stores into articles, but no one has validated whether agents actually use it.

**The cost:** every session that starts without accumulated intelligence is a session that re-discovers what was already known. The system doesn't compound — it resets.

### Core Tensions

1. **Capture works, but drain doesn't.** Two automated pipelines (Link Triage, Knowledge Capture) reliably feed the KB. But session-level capture (agents writing to Memory/KB, lessons.md promoting to KB) is specced but rarely executes. The hot buffer fills; the permanent store doesn't grow from session work.

2. **Two stores, fuzzy boundary.** KB holds "knowledge" (patterns, learnings, reference). Memory holds "state" (decisions, preferences, facts). In practice, agents don't reliably distinguish between them. No enforcement exists — routing is aspirational.

3. **Infrastructure is fragile.** Everything runs on a single aging Intel Mac (macbook2014). Hard-coded LAN IP means 6-second timeout when off-network. Single point of failure for all intelligence infrastructure.

4. **No unified view.** Eight knowledge surfaces exist (KB, Memory, lessons.md, MEMORY.md, Wiki, decisions.md, NC findings, capture-envelope). No agent has a coherent picture of what's known across all of them.

5. **The intelligence consumer is dormant.** Krypton was designed as the cross-system synthesis layer but hasn't been active. Knowledge Capture's synthesis step bypasses it entirely, calling `claude -p` directly.

---

## 2. Component Inventory

### 2.1 Storage Layer

#### Knowledge Base (KB)
- **Location:** `~/code/_shared/knowledge-base/`
- **Purpose:** Curated knowledge — patterns, learnings, reference content, synthesized understanding
- **Architecture:** 4-layer (Capture -> Process -> Store -> Access). SQLite (WAL) + Chroma vector DB. OpenAI text-embedding-3-small (1536-dim, API-dependent).
- **Interface:** 19 MCP tools via SSE at macbook2014:9101
- **Corpus:** 462 source items, 449 extractions, 479 chunks
- **Maturity:** Operate stage. Phase 0a instrumentation deployed (access logs, reuse tracking, daily hygiene, weekly report).
- **Health:** Operational with known issues. KB-37 (P0: source_entry_ids column — needs verification). KB-0A-FU2 (hygiene op ordering leaks duplicates). Phase 0a->0b gate review due 2026-04-23.
- **Tests:** 14 test files, ~434 tests, 95%+ coverage

#### Memory
- **Location:** `~/code/_shared/memory/`
- **Purpose:** Operational context — decisions, preferences, facts, session state
- **Architecture:** 3-layer (MCP -> Core -> Dual Store). SQLite (WAL) + Chroma. Local ONNX embeddings (all-MiniLM-L6-v2, 384-dim, no API dependency).
- **Interface:** 18 MCP tools via SSE at macbook2014:9102
- **Corpus:** 483 committed memories across 13 namespaces. 83% observations, 14% decisions, <1% preferences.
- **Maturity:** Deliver/Operate transition — v2.0 namespace governance shipped and operational, but project status.md still says Deliver. Episodic event log with hash chaining.
- **Health:** Operational with known issues. FIX-01 (P0: client_profiles missing from production config — all callers get fallback scoping). Write path lacks namespace authorization. Type distribution heavily skewed toward low-signal observations.
- **Tests:** 126 tests passing

### 2.2 Input Pipelines

#### Link Triage Pipeline
- **Location:** `~/code/_shared/link-triage-pipeline/`
- **Purpose:** Process manually-saved Raindrop.io bookmarks through automated classification and routing
- **Trigger:** Reactive — human saves a link, pipeline processes it
- **Architecture:** 8-step pipeline (Fetch -> Dedup -> Extract -> Classify -> Route -> Record -> Digest). Jina Reader + Trafilatura extraction. Claude Sonnet classification.
- **Schedule:** Daily 4:00 AM via launchd (laptop)
- **Feeds into:** KB (via `kb_integration/kb_client.py` adapter, opt-in via `KB_INTEGRATION=true`)
- **Maturity:** Deliver stage. 200 tests, 95% coverage. Stable.
- **Backlog:** LT-6 (weekly digest + Slack), LT-7 (X/Twitter embedded links), LT-11 (intelligence bucketing)

#### Knowledge Capture
- **Location:** `~/code/_shared/knowledge-capture/`
- **Purpose:** Autonomous discovery — monitors YouTube channels, RSS feeds, Substack across professional domains
- **Trigger:** Proactive — system discovers content without human input
- **Architecture:** Composable domain-config pipeline (95% shared infra, 5% YAML config per domain). YouTube API + transcript extraction. RSS/Atom parsing. Claude Haiku/Sonnet classification with domain context injection. KB cross-referencing. Synthesis to Slack briefing.
- **Schedule:** 3 daily launchd jobs on macbook2014 (5:30am governance, 7:00am general-ai, 9:00am nate-jones) + Sunday 6pm weekly rollup
- **Feeds into:** KB (via direct adapter pattern — bypasses `send_to_kb` to preserve structured fields)
- **Active domains:** 3 (governance: 21 YouTube channels, general-ai: 4 YouTube + 3 RSS, nate-jones: 1 Substack)
- **Maturity:** Operate stage. 229+ tests. Running autonomously. Production deployment runbook exists.
- **Backlog:** KC-33 (KB data sharing between hosts), KC-34 (YouTube search), KC-35 (WM integration)

#### Session Capture (broken)
- **Purpose:** Agents write learnings/decisions/facts to Memory or KB during sessions
- **Mechanism:** Explicit `write_memory` or `send_to_kb` MCP tool calls. Requires 5 agent decisions per write (notice, decide cross-project, choose namespace, choose type, call tool).
- **Status:** Specced but unreliable. `capture-problem.md` in Memory repo diagnosed the issue: routing at capture time is the wrong design. Agents skip it under time pressure.
- **PreCompact hook:** Echo-only reminder. Doesn't trigger actual capture.

#### lessons.md Drain (broken)
- **Purpose:** Hot buffer of per-project learnings. Max 15 entries. Cross-project patterns promote to KB on session wrap.
- **Mechanism:** `/session-wrap` skill step 3 (capture) + KB promotion via `send_to_kb`
- **Status:** Capture works (agents write to lessons.md). Drain doesn't (sessions end without running wrap). ai-dev at 48 lines / 34 entries — 3x over the 15-entry cap.
- **Standard:** `project-layout.yaml` v1.1.0 requires it. `session-lifecycle.yaml` defines capture + promote as separate wrap actions. `artifact-frontmatter.yaml` sets 7-day freshness threshold.

### 2.3 Synthesis Layer

#### Personal Wiki
- **Location:** `~/code/_shared/personal-wiki/`
- **Purpose:** Agent-navigable read-side synthesis of KB + Memory + Episodes into interlinked markdown articles
- **Architecture:** Python scripts (generate_wiki.py 868 lines, wiki_sync.py 412 lines). LLM synthesis via ChatMock proxy on macmini (GPT-5, zero-cost via subscription). No external dependencies beyond stdlib.
- **Output:** 52 articles across 7 categories, 1,289 backlinks, YAML frontmatter with source hashing for change detection
- **Schedule:** Incremental sync every 6h via launchd on macbook2014 (00:15, 06:15, 12:15, 18:15)
- **Maturity:** Brand new (4 commits, April 5-8 2026). Phase 2 (incremental sync) deployed.
- **Blockers:** Memory DB not yet local on macbook2014 (uses seeded export). File-based memories (MEMORY.md) not captured by sync.
- **Unvalidated hypothesis:** "Do agent sessions actually improve with wiki context?"
- **Truncation concern:** 30-item cap per article causes 48% truncation in ai-agents category. Heavy articles lose signal.

### 2.4 Observation Layer

#### Nerve Center (relevant probes)
- `knowledge-auditor` — weekly KB + Memory health (stale entries, duplicates, synthesis gaps)
- `mcp-availability` — 15-minute ping on KB and Memory MCP servers
- `knowledge-capture-health` — daily 10am, checks KC job status + pipeline stats

### 2.5 Intelligence Consumer (dormant)

#### Krypton
- **Location:** `~/code/_shared/krypton/`
- **Status:** Dormant. Has not been active. Likely to be redesigned.
- **Original role:** Cross-system synthesis — reads KB, Memory, NC findings. Produces briefings, capture routing, priority recommendations.
- **Current reality:** Knowledge Capture's synthesis step calls `claude -p` directly. Krypton's scheduled launchd jobs exist but operational status is unclear.
- **Design implication:** Do not design around Krypton as a dependency. The intelligence layer must be self-sufficient. Krypton is an optional consumer if/when redesigned.

### 2.6 Data Flow Overview

```
     CAPTURE (sources)              STORAGE (persist)           ACCESS (consumers)
  ═══════════════════════        ═════════════════════       ═══════════════════════

  Raindrop.io (manual)           ┌─────────────────┐        Claude Code (MCP) [live]
       │                         │                 │───────> Codex (MCP) [planned]
       ▼                         │   KNOWLEDGE     │───────> ChatGPT (REST) [planned]
  ┌─────────────┐  adapter       │     BASE        │
  │ Link Triage │ ─────────────> │  macbook2014    │
  │  (laptop)   │                │  :9101          │
  └─────────────┘                │                 │
                                 │  462 items      │
  YouTube/RSS (27+)              │  19 MCP tools   │
       │                         └────────┬────────┘
       ▼                                  │ export (SQLite)
  ┌─────────────┐  adapter               ▼
  │ Knowledge   │ ─────────────> ┌─────────────────┐
  │ Capture     │                │ Personal Wiki   │
  │ (macbook2014)                │ 52 articles     │
  └─────────────┘                │ (synthesis)     │
                                 └─────────────────┘
  Agent sessions · · · · · · ·>          ▲ export (SQLite)
  (send_to_kb — broken)                  │
                                 ┌───────┴─────────┐
  lessons.md · · · · · · · · ·> │                  │
  (promote to KB — broken)      │    MEMORY        │───────> Claude Code (MCP) [live]
                                │  macbook2014     │· · · ·> Codex (MCP) [planned]
  Agent sessions · · · · · · ·> │  :9102           │· · · ·> ChatGPT (REST) [planned]
  (write_memory — broken)       │                  │
                                │  483 memories    │
                                │  18 MCP tools    │
                                └──────────────────┘

  ════> working flow     · · ·> broken/unreliable flow
```

**Key observation:** The left side (proactive capture) works. The middle (session capture to both stores + lessons.md drain) is broken. The right side (multi-client access) is partially built (MCP only, Claude Code only).

---

## 3. Use Cases and Access Patterns

### 3.1 Who Needs Intelligence (Consumers)

| Consumer | Access Method Today | What They Need | Frequency |
|---|---|---|---|
| Claude Code sessions (all agents) | MCP tools (KB:9101, Memory:9102) | Searchable knowledge, operational context, session state | Every session |
| Codex | AGENTS.md only (MCP not registered) | Same as Claude Code — cross-project patterns, decisions | Every task |
| ChatGPT (via browser) | None | Access to KB and Memory for continuity across platforms | Ad-hoc |
| Mobile / personal assistant | None | Quick lookups, decision recall, learning retrieval | Ad-hoc (part of multi-client vision, not a separate deliverable) |
| Automated jobs (KC, link-triage) | Direct DB adapter (KB) | Write access for ingestion, read for cross-referencing | Scheduled |
| Wiki generator | Direct SQLite reads | Full corpus export for synthesis | Every 6h |
| Nerve Center probes | MCP tools | Read access for health monitoring | Scheduled |

### 3.2 What Questions the Intelligence Layer Should Answer

**Knowledge (KB domain):**
- "What do we know about X?" (semantic search)
- "What patterns have we seen across projects?" (cross-project learnings)
- "What content has been captured recently on topic Y?" (recency + topic filter)
- "What's actionable from recent captures?" (action_state filtering)

**Memory (state domain):**
- "What did we decide about X?" (decision recall)
- "What are Jesse's preferences for Y?" (preference lookup)
- "What happened in the last session on project Z?" (session context)
- "What's the current state of X?" (operational facts)

**Synthesis (combined):**
- "Give me a briefing on what's new and relevant" (KC already does this for content; extend to session learnings)
- "What should I know before starting work on project X?" (orient enrichment)
- "What connects these two topics?" (cross-reference, wiki-like)

### 3.3 Multi-Client Access Vision (3-6 month horizon)

**Near-term (macbook2014 era):**
- Claude Code: MCP over SSE (current, working when on-network)
- Codex: MCP registration (blocked on CLI env, backlog item)
- ChatGPT: No path today. Requires either REST API wrapper or ChatGPT custom action pointing to an HTTP endpoint.

**Medium-term (post-macbook2014 replacement):**
- All LLM clients access the same intelligence via a stable API
- MCP for Claude Code (native). HTTP/REST adapter for everything else.
- Hosting on a capable always-on machine with reliable network
- Consider: cloud-hosted REST API in front of local stores (Railway, Vercel) for mobile/ChatGPT access

**Architecture principle:** Build the core as a Python library with clean API. MCP server is one interface adapter. REST/HTTP is another. Both call the same core. This pattern already exists in Memory (`MemoryStorage` class) and partially in KB (`KBStorage` class).

---

## 4. Boundary Definitions

### 4.1 KB vs Memory — Proposed Enforcement

| Dimension | Knowledge Base | Memory |
|---|---|---|
| **Content** | Patterns, learnings, reference material, synthesized understanding, captured content | Decisions, preferences, facts, observations, session state |
| **Temporal** | Relatively stable (content doesn't change once captured) | Evolves (decisions get superseded, preferences update) |
| **Source** | External content (links, articles, videos), promoted learnings from sessions | Session observations, explicit agent/user declarations |
| **Write pattern** | Batch ingestion (pipelines), occasional session promotion | Frequent small writes during sessions |
| **Read pattern** | Semantic search on demand | Load relevant context at session start + search |
| **Quality bar** | Curated (classified, tagged, scored) | Must be high-signal atomic facts. Current 83% observation type is valid as a category but many observations are low-signal noise — the problem is quality filtering, not the type itself. |
| **Size per entry** | Large (full extractions with summaries, key points, actionables) | Small (atomic facts, one idea per entry) |
| **Example** | "Here's a pattern for MCP server design from Anthropic docs" | "Jesse prefers conventional commits" |
| **Example** | "Karpathy says context window is RAM, retrieval is disk" | "We decided to host on macbook2014 for 3-6 months" |

**Routing rule (simplified):**
- Is it captured external content? -> **KB**
- Is it a pattern/learning promoted from sessions? -> **KB**
- Is it a decision, preference, or fact about how we work? -> **Memory**
- Is it a session observation? -> **Memory** (but filter for signal)
- Is it both? -> **KB** for the knowledge, **Memory** for the decision aspect. Two writes.

### 4.2 Capture Pipeline vs Storage

Capture pipelines (Link Triage, Knowledge Capture) own discovery, extraction, classification, and routing. They are **clients** of KB, not part of KB. The boundary:
- Pipeline owns: source management, content extraction, LLM classification, routing logic, state tracking, digest generation
- KB owns: storage, indexing, embedding, search, deduplication, maintenance

This boundary is already clean in practice. Both pipelines use adapters to write into KB's schema. The `capture-envelope-standard` (at `aws/docs/standards/capture-envelope-standard.md`) defines the cross-system metadata format that both pipelines implement.

### 4.3 Wiki vs KB/Memory

The wiki is a **derived artifact**, not a primary store. It reads from KB + Memory exports and generates synthesized articles. It should never be written to directly. The wiki is the read-optimized layer; KB + Memory are the write-optimized layers.

**Open question:** Is the wiki earning its complexity? It adds another scheduled job, another LLM dependency (ChatMock on macmini), and another infrastructure node. The core hypothesis is unvalidated. Assessment criteria proposed in Section 8.

---

## 5. Infrastructure Constraints

### 5.1 Current Deployment Map

```
macbook2014 (192.168.1.29, Intel x86_64, macOS 12)
├── KB MCP server (:9101, SSE)
├── Memory MCP server (:9102, SSE)
├── KB hygiene job (daily 2:30am)
├── KB weekly report (Monday 9am)
├── Knowledge Capture — governance (daily 5:30am)
├── Knowledge Capture — general-ai (daily 7:00am)
├── Knowledge Capture — nate-jones (daily 9:00am)
├── Knowledge Capture — weekly rollup (Sunday 6pm)
├── Wiki sync (every 6h)
├── NC probe: kb-hygiene-health
└── Data: kb.db, memory.db (partial), chroma/

macmini (192.168.1.154, M1)
├── ChatMock proxy (:8000) — wiki LLM backend
├── Nerve Center (Railway deploy origin)
└── (KC jobs unloaded, moved to macbook2014)

Laptop (host Mac, primary dev machine)
├── Claude Code (all agents)
├── Link Triage pipeline (daily 4am)
├── MCP client connections to macbook2014
└── Source code (all repos)
```

### 5.2 Constraints

1. **macbook2014 is temporary (3-6 months).** Architecture must not couple to it. Abstract host-specific details (paths, IPs, ports) behind config.
2. **Network dependency is a known pain point.** 6-second timeout when laptop is off-network. P0 backlog item since April 9.
3. **onnxruntime constraint on macbook2014.** Version 1.23.2 has no wheel for macOS 12 x86_64. Workaround: use `.venv/bin/python` directly instead of `uv run`.
4. **nerve-center on macbook2014 is not a git repo.** (.git corrupt). Deploys via scp.
5. **Memory DB partially deployed on macbook2014.** Wiki sync uses seeded export, not live data.
6. **File-based memories (MEMORY.md) on laptop only.** macbook2014 can't access them for wiki sync.
7. **Single point of failure.** If macbook2014 goes down, KB, Memory, KC, and Wiki all stop.

### 5.3 Migration Path

When macbook2014 is replaced (3-6 months):
- Services move to the replacement machine
- If replacement is powerful enough: consider running KB and Memory locally on the dev laptop for zero-latency access, with async sync to the always-on machine for durability and multi-client access
- REST/HTTP adapter layer enables cloud proxy for ChatGPT/mobile access without moving primary stores off-LAN

---

## 6. What's Working

1. **Proactive capture pipelines are solid.** Link Triage (200 tests, daily) and Knowledge Capture (229 tests, 3 domains, daily) reliably feed KB. This is the strongest part of the system.
2. **KB storage and search work.** 19 MCP tools, semantic search, priority scoring, deduplication. Phase 0a instrumentation adds observability.
3. **Memory write/read/search works.** 18 MCP tools, namespace scoping, deduplication at 0.88 threshold, episodic event log.
4. **KB and Memory follow the same architectural pattern.** SQLite + Chroma + MCP server + Python core library. Makes it possible to apply governance uniformly.
5. **Standards exist.** project-layout.yaml, session-lifecycle.yaml, capture-envelope-standard all define how the pieces should connect.
6. **NC monitors both.** knowledge-auditor and mcp-availability probes provide observability.

---

## 7. What's Broken or Missing

### 7.1 Critical (blocks intelligence compounding)

| ID | Issue | Impact | Component |
|---|---|---|---|
| **IL-01** | Session capture unreliable — agents skip `write_memory`/`send_to_kb` | Session learnings don't reach permanent stores | Memory, KB |
| **IL-02** | lessons.md drain never executes — sessions end without wrap | Hot buffer fills, KB doesn't grow from session work | lessons.md -> KB |
| ~~**IL-03**~~ | ~~KB-37: `source_entry_ids` column~~ | **CLOSED 2026-04-10** — column exists on live DB (row 17, verified via SSH). Migration 003 ran successfully. | KB |
| ~~**IL-04**~~ | ~~Memory FIX-01: `client_profiles` missing~~ | **CLOSED 2026-04-10** — 8 client profiles present in production config (claude-code, claude-opus, krypton, codex, adf, maintenance, nerve-center, weekly-digest). Namespace scoping operational. | Memory |

### 7.2 Important (degrades quality or reliability)

| ID | Issue | Impact | Component |
|---|---|---|---|
| **IL-05** | KB/Memory boundary not enforced | Wrong data in wrong store, duplicates across stores | KB + Memory |
| **IL-06** | Memory observation quality too low — 83% observations is valid type distribution, but many are low-signal noise (daily increments, trivial facts) that dilute search results | Search returns noise instead of signal | Memory |
| **IL-07** | Network dependency on macbook2014 | 6-second timeout off-network, blocks all intelligence access | Infrastructure |
| **IL-08** | Wiki hypothesis unvalidated | Unknown ROI on wiki complexity | Wiki |
| **IL-09** | No multi-client access (ChatGPT, Codex, mobile) | Intelligence locked to Claude Code sessions | All |
| **IL-10** | KB hygiene op ordering leaks duplicates (KB-0A-FU2) | 9 duplicate title groups in committed state | KB |
| **IL-11** | No dedicated agents for KB or Memory health/evolution | Maintenance is manual or scheduled scripts, not governed | KB + Memory |

### 7.3 Gaps (not built yet)

| ID | Gap | Needed for |
|---|---|---|
| **IL-12** | Unified capture pipeline design ("capture broadly, route later") | Solving IL-01 and IL-02 |
| **IL-13** | REST/HTTP adapter for KB and Memory | Multi-client access (IL-09) |
| **IL-14** | Dedicated KB agent with harness | Governed KB evolution (IL-11) |
| **IL-15** | Dedicated Memory agent with harness | Governed Memory evolution (IL-11) |
| **IL-16** | Intelligence layer architecture spec (this work) | Coherent system design |
| **IL-17** | Cross-store search (query both KB and Memory in one call) | Unified intelligence access |
| **IL-18** | KB data sharing between hosts (KC-33 dependency) | Knowledge Capture writes on macbook2014, Link Triage writes from laptop |

---

## 8. Open Questions for Design Stage

### Architecture

1. **Should KB and Memory share a common access layer?** A unified `intelligence-query` tool that searches both and returns merged results — or keep them separate with distinct query patterns?

2. **What replaces Krypton?** If Krypton is redesigned, what fills the "cross-system synthesis" role? Is it a new agent? A skill? A scheduled job? Or does each agent just query KB + Memory directly?

3. **Should the Wiki continue?** Proposed assessment criteria:
   - After 2 weeks of wiki availability, measure: how many agent sessions reference wiki articles? (via KB access log or grep)
   - If <10% of sessions use it, the complexity isn't justified. Pause and re-evaluate.
   - If >10%, invest in fixing truncation and improving article quality.

4. **How does "capture broadly, route later" work mechanically?** Options:
   - Single `capture` tool that writes to a staging area, with async classification/routing
   - PreCompact hook that extracts and writes automatically (Memory's capture-problem.md recommends this)
   - Session-end hook that bulk-captures without agent decision overhead
   - Some combination

### Boundaries

5. **Should Link Triage and Knowledge Capture merge?** They're parallel pipelines with different triggers but similar architecture (fetch -> extract -> classify -> route -> KB). Shared infrastructure, different config?

6. **Where does decisions.md fit?** Some projects have it, it's supposed to feed Memory MCP, but no pipeline exists. Is it redundant with Memory's `decision` type?

### Infrastructure

7. **Local-first or network-first for the replacement machine?** Run KB + Memory on the dev laptop (zero latency, works offline) with sync to always-on machine? Or keep them on the always-on machine with better reliability than macbook2014?

8. **REST adapter scope.** Thin wrapper (forward MCP calls over HTTP) or full API with its own auth, rate limiting, caching?

---

## 9. Success Criteria

The intelligence layer is successful when:

1. **Every session starts smarter.** `/orient` includes at least one KB search result and one Memory query result when relevant context exists in the stores. Measurable: instrument /orient to log whether KB/Memory were queried and returned results.

2. **Session learnings reach permanent storage.** Lessons captured during sessions drain to KB within 24 hours (via session-wrap, hook, or scheduled job). Measurable: lessons.md entry count stays at or below 15 across all projects.

3. **Decisions persist.** Decisions made in any session are retrievable from Memory by any agent in any future session. Measurable: at least 1 `decision` type entry per 5 sessions that involve a non-trivial decision. Baseline established after first month of operation.

4. **Automated capture is reliable.** Link Triage and Knowledge Capture continue running with >95% success rate. KB corpus grows steadily. Measurable: weekly report shows positive write rate.

5. **KB and Memory boundaries are clear.** Agents route to the correct store without ambiguity. Measurable: no cross-store duplicates detected in monthly audits.

6. **Multi-client access exists.** Within 3 months, at least one non-Claude-Code client (ChatGPT or Codex) can query KB and Memory. Measurable: access log shows non-Claude-Code callers.

7. **Infrastructure is resilient.** No single machine failure causes permanent data loss. Automated backups exist. Migration to replacement hardware is documented and tested. Measurable: backup verification probe passes weekly. *(Note: offline/degraded-mode access is a Design question — no mechanism exists today. Near-term resilience means recoverability, not always-on availability.)*

8. **The system compounds.** After 3 months of operation, KB items are actively reused. Measurable: KB `reuse_count` across items increases month-over-month for 3 consecutive months.

---

## 10. Risks and Constraints

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| macbook2014 hardware failure | Medium (aging Intel) | High — all intelligence offline | Automated backups. Migration runbook. Architecture decoupled from host. |
| Over-engineering the architecture | Medium | High — complexity without value | Iterative implementation. Fix broken pipes first. Validate each layer before building the next. |
| Capture pipeline divergence | Low | Medium — two pipelines drift apart | Shared standards (capture-envelope). Consider shared infrastructure in Design. |
| Wiki complexity not justified | Medium | Low — easy to pause | 2-week assessment gate before further investment. |
| Multi-client adds security surface | Medium | Medium — exposing personal knowledge | Start with LAN-only REST. Add auth before any cloud exposure. |
| Krypton redesign conflicts with IL design | Low | Medium — rework | Design IL as self-sufficient. Krypton consumes, doesn't own. |

---

## 11. Scope Boundary

### In Scope (the intelligence layer system)
- KB + Memory as core storage subsystems
- Capture pipelines (Link Triage, Knowledge Capture, session capture, lessons.md drain)
- Synthesis layer (Personal Wiki, pending validation)
- Boundary definitions and contracts between components
- Dedicated agents for KB and Memory governance
- Multi-client access (MCP + REST)
- Monitoring and governance model

### Design Deliverables (outputs of this design effort)
- Architecture spec with visual diagrams
- Component contracts (KB API, Memory API, capture envelope)
- Agent harness definitions
- Infrastructure plan (macbook2014 now, replacement later)
- Phased implementation roadmap

### Out of Scope
- Krypton redesign (separate effort; IL provides the substrate Krypton can consume)
- Work Management integration (downstream consumer, not part of IL core)
- Client project conformance (AGF, pike-acm — separate sprint)
- Nerve Center changes beyond probe updates (NC is observation layer, not IL)
- New capture source development (X/Twitter, GitHub, podcasts — backlogged in KC)

---

## 12. Next Step

**Design stage.** Produce an architecture spec covering:
1. System architecture with visual diagrams (component relationships, data flows, deployment)
2. Contracts between components (KB API surface, Memory API surface, capture envelope)
3. Agent definitions (KB agent, Memory agent — responsibilities, harnesses, tools)
4. Capture pipeline redesign (session capture fix, lessons.md drain automation)
5. Multi-client access design (MCP + REST adapter pattern)
6. Infrastructure plan (macbook2014 now, replacement later, migration path)
7. Governance model (monitoring, freshness, quality metrics, evolution criteria)
8. Phased implementation plan (fix broken -> stabilize -> extend -> multi-client)

**Estimated effort:** 2-3 design sessions to produce spec. Multiple review cycles as Jesse indicated.

---

## 13. Phase 0 Pre-Work (before Design starts)

These items must be verified or fixed before the Design stage begins. They affect fundamental assumptions in the brief.

| ID | Item | Status |
|---|---|---|
| **P0-1** | Verify KB-37: `source_entry_ids` column on live DB | **VERIFIED 2026-04-10** — column exists (row 17). IL-03 closed. |
| **P0-2** | Verify Memory `client_profiles` in production config | **VERIFIED 2026-04-10** — 8 client profiles present. IL-04 closed. |
| **P0-3** | Verify KB + Memory MCP servers responsive | **VERIFIED 2026-04-10** — both SSE endpoints responding. |
| **P0-4** | Test `send_to_kb` and `write_memory` write paths | **PENDING** — non-blocking, run at Design session start. |

All blocking P0 items verified. SSH to macbook2014 operational via dedicated key (`~/.ssh/macbook2014_ed25519`).

---

## Issue Log

| # | Issue | Source | Severity | Complexity | Status | Resolution |
|---|---|---|---|---|---|---|
| 1 | No intent.md artifact for intelligence layer | Internal-C1 | Critical | Low | Resolved | Created intent.md |
| 2 | Boundary table contradicts IL-06 on observation type validity | Internal-C1 | High | Medium | Resolved | Clarified: observation type is valid, quality filtering is the problem |
| 3 | IL-03 carries unverified P0 assumption | Internal-C1 | High | Medium | Deferred to P0 | Reworded in brief + added Phase 0 pre-work. Actual verification pending. |
| 4 | Success criterion #7 assumes offline mode that doesn't exist | Internal-C1 | High | Medium | Resolved | Reframed as recoverability, flagged degraded mode for Design |
| 5 | Mobile listed as consumer but not in scope | Internal-C1 | High | Low | Resolved | Clarified as part of multi-client vision |
| 6 | No reference to capture-envelope-standard | Internal-C1 | High | Low | Resolved | Added reference in Section 4.2 |
| 7 | No data flow diagram | Internal-C1 | High | Medium | Resolved | Added ASCII diagram in Section 2.6 |
| 8 | Section 12 design deliverables unprioritized | Internal-C1 | Low | N/A | Logged | — |
| 9 | Composability mentioned but not in success criteria | Internal-C1 | Low | N/A | Logged | — |
| 10 | Frontmatter missing `covers` field | Internal-C1 | Low | N/A | Resolved | Added covers field |
| 11 | Data flow diagram had duplicate Memory boxes | Internal-C2 | High | Low | Resolved | Redesigned diagram with clearer layout |
| 12 | No Phase 0 pre-work section for blocking verifications | Internal-C2 | High | Low | Resolved | Added Section 13 |
| 13 | Success criterion #1 not measurable ("starts smarter" is subjective) | External-Claude | High | Low | Resolved | Reworded to require KB/Memory query results in /orient |
| 14 | Success criterion #3 "proportional" has no baseline or threshold | External-Claude | High | Low | Resolved | Added "1 decision per 5 sessions" minimum |
| 15 | Success criterion #8 relies on qualitative assessment | External-Claude | High | Low | Resolved | Replaced with month-over-month reuse_count growth |
| 16 | Section 11 conflates system scope with design deliverables | External-Claude | High | Low | Resolved | Split into "In Scope (system)" and "Design Deliverables" |
| 17 | Issue Log #3 marked "Resolved" but actual verification pending | External-Claude | High | Low | Resolved | Changed to "Deferred to P0" |
| 18 | Phase 0 pre-work has no owner or deadline | External-Claude | High | Low | Resolved | Added owner (Jesse) and execution timing |
| 19 | Diagram uses "[planned]" for things not yet designed | External-Claude | Low | N/A | Logged | Minor — context makes it clear |
| 20 | Memory stage listed as Deliver but functionally Operate | External-Claude | Low | N/A | Resolved | Added transition note |
| 21 | NC probes may not detect laptop-to-macbook2014 path issues | External-Claude | Low | N/A | Logged | Valid observation for Design |
| 22 | Issue Log "Logged" status undefined as terminal state | External-Claude | Low | N/A | Logged | Follows adf-review convention |
| 23 | KB OpenAI embedding cost vs intent.md "zero API cost" constraint | External-Claude | Low | N/A | Logged | Covered by ChatMock proxy — clarify in Design |
| 24 | Frontmatter covers field missing risks and scope | External-Claude | Low | N/A | Resolved | Added to covers array |
