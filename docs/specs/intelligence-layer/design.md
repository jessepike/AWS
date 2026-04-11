---
title: Intelligence Layer — Design Specification
version: 1.0.0
stage: design-complete
updated: 2026-04-10
author: Forge (with Jesse)
status: complete
type: workflow
covers: [architecture, capture-pipeline, access-layer, data-flow, error-handling, triggers, integration-points, orchestration, decisions, capabilities, backlog]
---

# Intelligence Layer — Design Specification

**Intent:** [intent.md](intent.md)
**Brief:** [discover-brief.md](discover-brief.md)

## 1. Summary

This design specifies the Intelligence Layer (IL) — a unified knowledge and memory substrate for the Agentic Work System. The IL fixes two broken pipes (session capture and lessons.md drain), enforces the KB/Memory boundary via async classification, and establishes a tiered access model that aligns with how Claude Code, Codex, and future clients consume persistent intelligence.

The core architectural move: **separate capture from classification**. Agents append to flat-file hot buffers with near-zero friction. An async classifier routes entries to the correct cold store (KB or Memory). This eliminates the 5-decision write overhead that caused session capture to fail reliably.

**Project type:** Workflow (capture pipelines, scheduled jobs, hook automation, multi-store routing)

---

## 2. Architecture

### 2.1 Three-Tier Storage Model

Inspired by Karpathy's LLM OS analogy (context window = RAM, retrieval = disk) and Claude Code's own memory architecture (CLAUDE.md hot layer, MEMORY.md warm layer, topic files on demand).

```
TIER 1 — HOT (flat files, loaded at session start, git-versioned)
├── captures.md     — append-only staging buffer, async-routed to cold stores
├── lessons.md      — per-project learnings, max 15, cross-project → KB
├── decisions.md    — per-project decisions, → Memory (decision type)
├── CLAUDE.md       — human-curated instructions (loaded every turn)
└── MEMORY.md       — Claude auto-memory index (loaded first 200 lines)

TIER 2 — WARM (structured files, loaded on demand)
├── MEMORY.md topic files  — Claude auto-memory detail (pulled when relevant)
├── Wiki articles          — synthesized narratives (filesystem crawl)
└── status.md / BACKLOG.md — operational state

TIER 3 — COLD (databases, queried via MCP tools)
├── Knowledge Base   — SQLite + Chroma, 19 MCP tools, semantic search
│                      Curated knowledge: patterns, learnings, reference
└── Memory           — SQLite + Chroma, 18 MCP tools, fact lookup
                       Operational context: decisions, preferences, facts
```

**Design principle:** Write to hot tier (cheap, fast, zero routing). Promote to cold tier asynchronously (classified, governed, searchable). Read from any tier based on query type.

**Karpathy alignment:** His three operations map directly — Ingest (capture to hot), Query (search cold), Lint (periodic health sweep). His `log.md` pattern validates append-only flat-file staging.

**Anthropic alignment:** Claude Code uses CLAUDE.md (hot, every turn) + MEMORY.md (warm, 200 lines) + topic files (cold, on demand). The 200-line/25KB limit is calibrated — adherence degrades above this threshold.

### 2.2 Component Relationships

```
CAPTURE SOURCES                  HOT BUFFER              ASYNC CLASSIFIER           COLD STORES
═══════════════                  ══════════              ════════════════           ═══════════

Agent sessions ──────────┐
                         ├────> captures.md ──────┐
PreCompact hook ─────────┘                        │
                                                  ├──> Classifier ──┬──> KB (knowledge)
Agent sessions ──────────────> lessons.md ────────┤    (Haiku)      │
                                                  │                 └──> Memory (facts)
Agent sessions ──────────────> decisions.md ──────┘

Link Triage ─────────────────────────────────────────────────────────> KB (direct adapter)
Knowledge Capture ───────────────────────────────────────────────────> KB (direct adapter)
```

**Key:** Existing pipelines (Link Triage, Knowledge Capture) bypass the hot buffer — they have their own classification and route directly to KB. The hot buffer + async classifier only handles session-originated content.

### 2.3 What's In Scope vs Out

| Component | Role in IL | Owned by IL? |
|-----------|-----------|-------------|
| KB (storage + MCP) | Cold knowledge store | Yes — core |
| Memory (storage + MCP) | Cold fact store | Yes — core |
| captures.md / lessons.md / decisions.md | Hot buffers | Yes — core |
| Async classifier | Routes hot → cold | Yes — new |
| `intelligence_query` tool | Unified read across cold stores | Yes — new |
| PreCompact hook (upgraded) | Capture safety net | Yes — new |
| Session-end hook | Trigger classifier fast path | Yes — new |
| Lint harness job | Periodic health sweep | Yes — new |
| Link Triage | External content pipeline | No — existing consumer of KB |
| Knowledge Capture | Autonomous discovery pipeline | No — existing consumer of KB |
| Personal Wiki | Synthesis layer | No — optional consumer, out of core |
| Krypton | Cross-system synthesis | No — optional consumer if redesigned |

---

## 3. Capture Pipeline Redesign

### 3.1 The Problem (from capture-problem.md)

Session capture requires 5 agent decisions per write: notice → cross-project relevance → namespace → type → tool call. This cognitive overhead gets skipped reliably under time pressure. The fundamental design mistake was putting routing decisions on the agent at capture time.

### 3.2 Design: Capture Broadly, Route Later

**Agent responsibility:** ONE decision — "this is worth capturing." Append one line to the appropriate hot buffer file. No namespace, no type, no store selection.

**Three hot buffer files, each with a clear trigger:**

| File | Agent writes when... | Format | Routed to |
|------|---------------------|--------|-----------|
| `captures.md` | Anything worth remembering that isn't clearly a lesson or decision | `- YYYY-MM-DD: <content>` | KB or Memory (classifier decides) |
| `lessons.md` | A specific insight or pattern learned | `- YYYY-MM-DD: <content>` | KB (cross-project) or stays (project-only) |
| `decisions.md` | A decision was made with rationale | `- YYYY-MM-DD: <decision> — <rationale>` | Memory (decision type) |

**Why three files, not one:** Each has a different promotion target and retention policy. lessons.md already exists with a 15-entry cap. decisions.md maps directly to Memory's `decision` type. captures.md is the catch-all for everything else. Agents already understand "is this a lesson, a decision, or something else?" — that's a lightweight classification, not the 5-step overhead that kills capture.

### 3.3 Hot Buffer Spec

**Format:** Markdown, one entry per line, date-prefixed. Append-only during sessions.

```markdown
# Captures — {project-name}

- 2026-04-10: FastMCP returns content[0].text not .result — caught during KB adapter debugging
- 2026-04-10: macmini ChatMock proxy needed for wiki generation — single point of failure for synthesis
- 2026-04-11: PreCompact hook can inject text but cannot make MCP tool calls directly
```

**Properties:**
- Git-versioned (committed with session work)
- Human-readable and editable
- No frontmatter required (keeps append friction at zero)
- Entries marked as processed by the classifier get removed (file stays lean)
- Maximum size: no hard cap, but classifier should process and trim regularly

### 3.4 PreCompact Hook (Upgraded)

**Current state:** Echo-only reminder ("remember to capture before compaction").

**New behavior:** Structured extraction prompt that appends to captures.md.

```
Hook: PreCompact
Type: command
Command: echo "CAPTURE CHECK: Before compacting, review this session for:
1. Cross-project learnings → append to captures.md or lessons.md
2. Decisions made → append to decisions.md  
3. Facts discovered → append to captures.md
Append entries now. Format: '- YYYY-MM-DD: <content>'"
```

**Constraint:** PreCompact hooks can inject text into conversation but cannot make MCP tool calls. This is why we write to flat files (filesystem access works) rather than calling `write_memory` or `send_to_kb` from the hook.

**Standard update required:** `session-lifecycle.yaml` v1.0.0 defines pre-compact-hook as "Reminder only — no writes, no reads." This upgrade changes it to produce writes (agent appends to hot buffer files after receiving the extraction prompt). The standard must be updated to reflect this new behavior before or during Phase 1 implementation. The hook itself still only injects text — the *agent* does the writing in response.

**This is the safety net, not the primary path.** The primary path is agents writing to hot buffers during normal session work. PreCompact catches what they miss before context is lost.

### 3.5 Async Classifier

**Purpose:** Read hot buffer files, classify each entry, route to the correct cold store, remove processed entries.

**Implementation:** Single-pass design. One `claude -p` call (NOT `--bare` — bare skips auth and loses MCP access) with MCP tool access. MCP access comes from **global settings** (`~/.claude.json`) where KB and Memory servers are configured as stdio transports — this means `claude -p` launched from any directory can reach both stores without per-project `.mcp.json`. The prompt includes all hot buffer contents and instructs the LLM to: (1) classify each entry, (2) call `send_to_kb` or `write_memory` directly for entries that should promote, (3) output a JSON manifest of actions taken. The script parses the manifest to know which entries were routed, then updates the hot buffer files and commits.

**Classifier output schema:**
```json
[
  {"entry": "FastMCP returns content[0].text...", "source_file": "captures.md", "action": "kb", "kb_type": "learning", "domain": "mcp"},
  {"entry": "Decided to host on macbook2014...", "source_file": "decisions.md", "action": "memory", "memory_type": "decision", "namespace": "global"},
  {"entry": "Fixed typo in config", "source_file": "captures.md", "action": "discard", "reason": "low-signal"},
  {"entry": "This repo uses pnpm", "source_file": "captures.md", "action": "keep", "reason": "project-specific"}
]
```

The LLM both classifies AND routes in a single pass — no two-phase call. The JSON manifest is the receipt: the script uses it to know which lines to remove from which files.

**Trigger:** Two paths (belt + suspenders):
1. **Session-end hook** — processes staging on clean session close. Fast path — captures from this session are routed before the next session starts. Uses `claude -p` with Haiku.
2. **Scheduled job (every 4h)** — sweeps up anything missed by the session-end hook (crashed sessions, abandoned sessions). Same classifier logic, timer-triggered. Runs via launchd.

**Why both:** Sessions end in many ways — clean wrap, crash, compaction, user closes terminal. The hook only fires on clean exits. The timer is the safety net. Together they satisfy success criterion #2 ("within 24 hours" — actually within 4 hours worst case).

**Project discovery:** The session-end hook runs in the current project directory (it knows which hot buffers to process). The scheduled sweep must discover all projects. It uses a find over known code directories (`~/code/_shared/`, `~/code/tools/`, `~/code/clients/`) looking for `captures.md`, `lessons.md`, or `decisions.md`. Only files with entries are processed. This is the same discovery pattern used by the existing NC knowledge-auditor probe.

**Client project boundary:** The sweep processes `~/code/clients/` projects. Client work learnings route to the personal KB/Memory alongside internal projects — this is intentional (cross-project learning is the core value proposition). If a client project contains confidential learnings that should NOT enter the personal knowledge stores, add a `.il-exclude` marker file to the project root. The classifier skips projects with this marker. Default: include all projects.

**Classification logic:**

```
For each unprocessed entry in captures.md:
  1. Is this a pattern, learning, or reference content?
     → send_to_kb (type: learning, domain: inferred from content)
  2. Is this a fact, preference, or decision about how we work?
     → write_memory (namespace: global, type: inferred)
  3. Is this project-specific only?
     → Leave in hot buffer (stays in captures.md for project context)
  4. Is this low-signal noise?
     → Remove (don't promote)

For each entry in lessons.md over the 15-entry cap:
  1. Does it have cross-project value?
     → send_to_kb, then remove from lessons.md
  2. Is it project-specific only?
     → Remove (already served its purpose as session context)

For each entry in decisions.md:
  1. Route to Memory (type: decision, namespace: project or global)
  2. Remove from decisions.md after successful write
```

**Idempotency — snapshot-and-mark pattern:** To prevent duplicates and handle partial failures:

1. **Snapshot:** Read all unmarked entries from hot buffer files into memory. This is the batch to process.
2. **Route:** The single-pass `claude -p` call receives the snapshot contents, classifies each entry, and writes to KB/Memory via MCP tools. Returns JSON manifest of actions taken.
3. **Mark done:** For each successfully routed entry (per manifest), remove it from the hot buffer file. For entries that failed to route (MCP error, timeout), mark them with a `[pending]` prefix: `- [pending] 2026-04-10: content`. Commit all file changes.

**On next run:**
- Unmarked entries: process normally (new entries since last run).
- `[pending]` entries: retry routing. If retry succeeds, remove. If a `[pending]` entry fails 3 consecutive runs, mark it `[failed]` and skip — operator reviews manually.
- `[failed]` entries: skip (operator must unmark to retry or delete).

**Failure modes:**
- Crash before route: Nothing changed on disk. Next run processes the same snapshot. No duplicates.
- Crash during route (some entries written, some not): Manifest not returned. NO entries removed from file. Next run reprocesses all. Cold stores may receive duplicates for entries that succeeded before crash — acceptable at personal scale (KB and Memory dedup thresholds catch near-duplicates, and lint sweep detects exact duplicates weekly).
- Crash after route, before mark: Same as above — reprocess, dedup catches it.
- Clean completion: All routed entries removed, failed entries marked `[pending]`.

**Concurrency control:** A per-project lockfile (`/tmp/il-classifier-{project-hash}.lock`) prevents the session-end hook and scheduled sweep from racing on the same project. If the lock exists, the second invocation skips that project (the first will handle it). Stale locks (>30 minutes old) are automatically removed.

**Git commit scoping:** The classifier stages ONLY the hot buffer files it modified (`git add captures.md lessons.md decisions.md`) — never `git add .` or `git add -A`. If the index has unrelated staged work, the classifier's commit only includes its own files. If the hot buffer files themselves have merge conflicts (rare — only if two sessions modified the same file), the classifier logs an error and skips that project.

**KB duplicate caveat:** KB deduplicates by `canonical_url` only (designed for pipeline ingestion of web content). It has no content-similarity dedup on `send_to_kb`. If a crash recovery causes the classifier to re-route an entry, KB stores a duplicate. Memory has 0.92 similarity threshold dedup, so it's safer. Mitigation: the lint sweep (weekly) detects and flags KB duplicates. At personal scale, occasional crash-induced duplicates are tolerable — the lint sweep is the cleanup mechanism, not prevention.

**Quality filter:** The classifier applies the routing heuristic from `memory-routing.md` — "Does this knowledge matter beyond the current project and current client?" This is the boundary enforcement mechanism that was missing.

### 3.6 lessons.md Drain (Specific Case)

The lessons.md drain is a specific case of the async classifier:
- Entries that have cross-project value promote to KB via `send_to_kb`
- Entries that are project-only get trimmed when file exceeds 15 entries
- Current ai-dev overflow (34 entries) gets resolved on first classifier run

---

## 4. Access Layer

### 4.1 Tiered Access (from reference-routing.md)

The routing table is already established. This design formalizes it:

| Query Type | Tier | Store | Access Method |
|-----------|------|-------|--------------|
| Recent project insights | Hot | lessons.md | File read at session start |
| Session state, next steps | Warm | status.md, BACKLOG.md | File read |
| Narrative context, orientation | Warm | Wiki articles | Filesystem crawl (Read/Glob/Grep) |
| Specific fact (host, port, decision) | Cold | Memory MCP | `search_memories` / `get_memory` |
| Semantic query ("anything about X") | Cold | KB MCP | `search_knowledge` |
| Cross-store query (both KB + Memory) | Cold | Both | `intelligence_query` (new) |

### 4.2 intelligence_query — Unified Read Layer

**New convenience tool** that searches both cold stores in one call.

**Behavior:**
1. Takes a natural language query
2. Searches KB (`search_knowledge`) and Memory (`search_memories`) in parallel
3. Deduplicates results (same content in both stores)
4. Labels each result with source store (KB or Memory)
5. Ranks by relevance, returns top N

**Implementation:** MCP tool on the KB server (or a thin wrapper MCP). Calls both stores' search APIs, merges results.

**Use cases:**
- `/orient` enrichment — "what do we know about this project across all stores?"
- Cross-reference queries — "what connects topic A to topic B?"
- Briefing preparation — "summarize all intelligence on X"

**Constraints:**
- Read-only. Never writes.
- Does not replace direct KB or Memory queries. Agents that know which store they want should use the specific tool.
- Results clearly labeled with source — consumers always know where data came from.

### 4.3 Anti-Patterns (from reference-routing.md)

These are already documented and remain in force:
- Don't store derivable facts in Memory (query the source)
- Don't use KB semantic search for exact fact lookups (use Memory)
- Don't wrap the wiki in MCP (filesystem-native is correct)
- Don't load lessons.md mid-session (session-start only)
- Don't promote to Memory what should stay in lessons.md

---

## 5. Orchestration

### 5.1 Capture Flow (per session)

```
SESSION START
  │
  ├─ /orient reads: CLAUDE.md, status.md, BACKLOG.md, lessons.md
  ├─ Auto-memory loads MEMORY.md (first 200 lines)
  └─ (Optional) intelligence_query for cross-project context
  
DURING SESSION
  │
  ├─ Agent appends to captures.md (worth remembering)
  ├─ Agent appends to lessons.md (specific insight)
  └─ Agent appends to decisions.md (decision + rationale)
  
PRE-COMPACT (hook fires)
  │
  └─ Structured extraction prompt → agent appends to hot buffers
  
SESSION END
  │
  ├─ /session-wrap updates status.md, BACKLOG.md, commits
  ├─ Session-end hook triggers async classifier (fast path)
  │    ├─ Reads captures.md, lessons.md, decisions.md
  │    ├─ Classifies each entry (Haiku)
  │    ├─ Routes to KB or Memory
  │    └─ Removes processed entries
  └─ Commit hot buffer changes
  
SCHEDULED (every 4h)
  │
  └─ Timer sweep runs same classifier logic (catches missed sessions)
```

### 5.2 Existing Pipeline Integration

Link Triage and Knowledge Capture continue unchanged. They are clients of KB, not part of the hot buffer system. Their architecture is proven (200+ tests each, >95% success rate).

**No merge.** Different triggers (manual vs autonomous), different schedules, different hosts (laptop vs macbook2014). Shared standard (`capture-envelope-standard.md`) ensures metadata consistency. Merging risks breaking two working things.

### 5.3 Session Lifecycle Integration

The capture flow integrates with the existing session lifecycle standard (`session-lifecycle.yaml`):

| Lifecycle Event | IL Action |
|----------------|-----------|
| orient | Read hot buffers, optionally query cold stores |
| work | Append to hot buffers as discoveries happen |
| pre-compact | Extraction prompt → hot buffers |
| session-wrap | Trigger classifier, commit hot buffer changes |
| session-handoff | Same as wrap, plus handoff block |

---

## 6. Integration Points

### 6.1 MCP Servers (existing)

| Server | Transport | Host | Tools |
|--------|-----------|------|-------|
| KB | stdio (local) | Laptop | 19 tools |
| Memory | stdio (local) | Laptop | 18 tools |

Both migrated from SSE (macbook2014) to stdio (local) on 2026-04-10. Zero-latency, no network dependency for read/write.

### 6.2 Capture Envelope v2

Extend `capture-envelope-standard.md` to cover session captures:

**v1 covers:** Pipeline captures (Link Triage, Knowledge Capture) with full envelope schema.

**v2 adds:** Session capture entries from hot buffers. Lighter envelope — the classifier generates the full envelope at processing time, not the agent at capture time.

```json
{
  "schema_version": "aws.capture-envelope.v2",
  "source": "session",
  "source_ref": "captures.md:line:7",
  "raw_text": "FastMCP returns content[0].text not .result",
  "project_hint": "knowledge-base",
  "classified_at": "2026-04-10T15:30:00Z",
  "route": {
    "primary_target": "memory",
    "strategy": "memory_write",
    "memory_type": "observation",
    "namespace": "global"
  }
}
```

The classifier generates this envelope. The agent never sees it.

### 6.3 Hook Integration

| Hook | Event | Action |
|------|-------|--------|
| PreCompact (existing, upgraded) | Before context compaction | Extraction prompt → hot buffers |
| Session-end (new) | Stop event | Trigger async classifier |

### 6.4 Scheduled Jobs

| Job | Schedule | Host | Action |
|-----|----------|------|--------|
| Classifier sweep | Every 4h | Laptop (launchd) | Process hot buffers across all projects |
| KB hygiene | Daily 2:30am | macbook2014 (launchd) | Existing — dedup, stuck items, embedding health |
| KB weekly report | Sunday 11am | macbook2014 (launchd) | Existing — corpus stats, Phase 0a gate |
| Lint sweep | Weekly (Sunday) | Laptop (launchd) | New — contradiction detection, orphans, staleness |

---

## 7. Error Handling

### 7.1 Failure Modes

| Failure | Impact | Mitigation |
|---------|--------|-----------|
| Session ends without clean wrap | Hot buffer entries not classified | Timer sweep picks up within 4h |
| Classifier fails mid-run | Some entries not routed | Entries stay in file, next run picks up (idempotent) |
| KB MCP unreachable | Can't route knowledge entries | Classifier retries next run. Hot buffer retains entries. |
| Memory MCP unreachable | Can't route fact entries | Same — retry on next run |
| macbook2014 down | KC and wiki stop. KB/Memory unaffected (local stdio) | Automated backups. Captures continue to hot buffers. |
| Laptop offline | No sessions, no classifier | Hot buffers persist in git. Resume on reconnect. |
| captures.md grows too large | File becomes unwieldy | Classifier trims on every run. Alert if >50 entries after processing. |

### 7.2 Degraded Mode

If both cold stores are unreachable, the system degrades gracefully:
- Hot buffers still work (flat files, no MCP dependency)
- Agents still capture to captures.md, lessons.md, decisions.md
- Classifier queues entries until stores are reachable
- No data loss — entries persist in git-versioned files

---

## 8. Boundary Enforcement (IL-05)

### 8.1 Write Boundary

The async classifier IS the enforcement mechanism:

| Content Type | Routing Rule | Target Store |
|-------------|-------------|-------------|
| Pattern, learning, reference content | `reference-routing.md` rule 2 | KB |
| External captured content (pipeline) | Direct adapter (existing) | KB |
| Decision with rationale | `memory-routing.md` decision table | Memory |
| Preference, fact about how we work | `memory-routing.md` litmus test | Memory |
| Cross-project observation (high signal) | `memory-routing.md` litmus test | Memory |
| Project-specific only | Stays in hot buffer | Neither (stays local) |
| Low-signal noise | Removed | Neither (discarded) |

Agents bypass this by using `send_to_kb` or `write_memory` directly — that's intentional. Experienced agents that know the routing rules can go direct. The classifier catches everything else.

### 8.2 Read Boundary

Flexible. Agents query whichever store fits their need:
- Specific fact → Memory
- Semantic search → KB
- Both → `intelligence_query`
- Narrative → Wiki filesystem crawl

No enforcement needed on reads. The routing table in `reference-routing.md` is guidance, not a gate.

---

## 9. Maintenance (Harness Jobs, Not Agents)

No dedicated KB or Memory agents. Maintenance runs as scheduled harness jobs extending the existing pattern (KB hygiene.py, weekly_report.py).

### 9.1 Existing Jobs (unchanged)

- KB hygiene (daily): dedup, stuck items, embedding health
- KB weekly report (Sunday): corpus stats, Phase 0a→0b gate

### 9.2 New Jobs

| Job | Schedule | Purpose |
|-----|----------|---------|
| **Classifier sweep** | Every 4h | Process hot buffer entries across all projects |
| **Lint sweep** | Weekly | Contradiction detection, orphan pages, stale facts (Karpathy lint pattern) |
| **Memory quality filter** | Weekly | Flag low-signal observations, check namespace consistency |
| **Backup verification** | Weekly | Verify KB + Memory backups exist and are recent |

### 9.3 Lint Sweep (Karpathy Pattern)

Karpathy's `log.md` + wiki pattern includes a "lint" operation — periodic health checks for contradictions, orphaned pages, and stale claims. Applied to IL:

**Checks:**
1. **Contradictions** — KB entries that conflict with Memory facts (e.g., KB says "use X", Memory says "decided against X")
2. **Orphaned entries** — KB extractions with no source item, Memory entries referencing deleted namespaces
3. **Staleness** — Memory facts older than 90 days without access, KB entries with zero reuse after 60 days
4. **Boundary violations** — KB entries that should be in Memory (atomic facts) or vice versa (structured knowledge)
5. **Hot buffer overflow** — lessons.md over 15 entries, captures.md over 50 entries after processing

**Output:** Report to `~/.logs/il-lint-{date}.md`. Alert via existing NC probe pattern if critical issues found.

---

## 10. Infrastructure Plan

### 10.1 Current State (macbook2014 era)

```
Laptop (primary)                    macbook2014 (secondary)
├── KB MCP (stdio, local)           ├── KC pipelines (3 daily jobs)
├── Memory MCP (stdio, local)       ├── KB hygiene (daily)
├── Hot buffer files (git)          ├── KB weekly report (Sunday)
├── Async classifier (launchd)      ├── Wiki sync (6h)
├── Lint sweep (weekly)             ├── KB SSE server (secondary)
├── Link Triage (daily)             └── Memory SSE server (secondary)
└── All agent sessions
```

**Local-first.** KB + Memory primary on laptop via stdio. macbook2014 runs capture pipelines and scheduled maintenance. No network dependency for session intelligence access.

### 10.2 Migration Path (post-macbook2014)

When macbook2014 is replaced:
1. KC pipelines move to replacement machine
2. If replacement is capable: consider running KB + Memory on both laptop (primary, stdio) and replacement (secondary, SSE for multi-client)
3. REST adapter added to replacement machine for ChatGPT/mobile access (thin wrapper over core library)

**Architecture is portable.** No macbook2014-specific coupling. Paths, ports, and hostnames are in config, not code.

### 10.3 Multi-Client Access (deferred)

Not in scope for this implementation. The core library pattern (`KBStorage`, `MemoryStorage`) already exists in both projects. When multi-client is needed:
1. Add thin REST/HTTP wrapper over existing Python core library
2. Deploy on always-on machine
3. API key auth (LAN-only initially, add proper auth before cloud exposure)
4. `intelligence_query` works the same over REST as over MCP

---

## 11. Decision Log

| # | Decision | Rationale | Implication |
|---|----------|-----------|-------------|
| D1 | Flat-file hot buffers (captures.md, lessons.md, decisions.md) — not SQLite staging | Git-versioned, human-readable, zero-friction append, works from hooks. Karpathy log.md + Claude MEMORY.md validate this pattern. | Classifier must read/modify markdown files, not query a DB. |
| D2 | Async classification — not routing at capture time | Production consensus (Mem0, Letta, Karpathy). Agents skip writes when writes are expensive. One-decision capture + async routing fixes this structurally. | Need classifier job + session-end hook. Latency: minutes to hours, not instant. |
| D3 | Session-end hook + 4h timer sweep (both) | Sessions end in many ways. Hook catches clean exits. Timer catches everything else. Belt + suspenders. | Two trigger paths, same classifier logic. Idempotent processing. |
| D4 | No dedicated KB/Memory agents — harness jobs only | Maintenance is batch work (hygiene, quality, lint), not interactive design. Existing pattern (hygiene.py, weekly_report.py) works. Avoids agent ownership ambiguity with Forge. | Extend existing scripts. No new pike-agents. |
| D5 | Wiki out of core architecture | 4 commits old, hypothesis unvalidated, depends on down macmini. Clean KB/Memory APIs reduce wiki's value proposition. | Wiki is optional consumer. 2-week assessment gate before further investment. |
| D6 | Keep Link Triage and KC separate | Both work (200+ tests each). Different triggers, schedules, hosts. Shared standard ensures consistency. | No pipeline merge. Capture envelope v2 extends shared standard. |
| D7 | `intelligence_query` as convenience, not replacement | Unified query is useful for /orient and briefings. But agents that know which store they want should use specific tools. Read boundary is flexible. | Three query tools: search_knowledge, search_memories, intelligence_query. |
| D8 | Local-first hosting (stdio) | Already migrated. Zero latency, works offline. Industry consensus for personal systems. | macbook2014 runs pipelines + maintenance, not primary storage access. |
| D9 | Capture envelope v2 for session captures | Extends existing standard. Classifier generates full envelope at processing time — agents never see it. | Backward compatible. v1 pipelines unchanged. |
| D10 | PreCompact hook upgraded from echo to extraction prompt | Hook can inject text but not call MCP tools. Flat-file writes work from hooks. Safety net for missed captures. | Hook writes to filesystem, not MCP. |

---

## 12. Capabilities Needed

### 12.1 Runtime

- Python 3.11+ (existing — KB and Memory both use this)
- Claude Code hooks (PreCompact, Stop — existing infrastructure)
- launchd (existing — scheduler for all jobs)
- `claude -p` (existing — for classifier Haiku calls)

### 12.2 New Components to Build

| Component | Type | Complexity | Dependencies |
|-----------|------|-----------|-------------|
| PreCompact hook upgrade | Hook config change | Low | settings.json |
| Session-end hook (classifier trigger) | Hook + script | Medium | `claude -p`, KB MCP, Memory MCP |
| Classifier script | Shell script invoking `claude -p` | Medium | `claude -p` (Haiku), KB + Memory MCP access via project config, git |
| Classifier launchd job | launchd plist | Low | Classifier script |
| `intelligence_query` MCP tool | MCP tool addition | Medium | KB server, Memory server |
| Lint sweep script | Python script | Medium | KB + Memory read access |
| Lint launchd job | launchd plist | Low | Lint script |
| captures.md scaffold | Markdown template | Trivial | adf-init update |
| decisions.md scaffold | Markdown template | Trivial | adf-init update |
| Capture envelope v2 | Standard update | Low | capture-envelope-standard.md |

### 12.3 Existing Components (unchanged)

- KB MCP server (19 tools, stdio)
- Memory MCP server (18 tools, stdio)
- Link Triage pipeline
- Knowledge Capture pipeline
- KB hygiene + weekly report jobs
- NC probes (kb-hygiene-health, mcp-availability)
- session-wrap skill
- orient skill

---

## 13. Success Criteria (from Brief, verified measurable)

| # | Criterion | Measurement | Target |
|---|-----------|------------|--------|
| SC-1 | Every session starts smarter | /orient logs KB + Memory query results | At least one result when relevant context exists |
| SC-2 | Session learnings reach permanent storage | lessons.md entry count across all projects | At or below 15 per project, sustained |
| SC-3 | Decisions persist | Memory `decision` type entry rate | At least 1 per 5 sessions with non-trivial decisions |
| SC-4 | Automated capture reliable | KC + Link Triage success rate in weekly report | >95% success, positive write rate |
| SC-5 | KB/Memory boundaries clear | Cross-store duplicate detection in lint sweep | No cross-store duplicates in monthly audits |
| SC-6 | Multi-client access exists | Access log shows non-Claude-Code callers | Within 3 months (deferred — REST adapter not in Phase 1) |
| SC-7 | Infrastructure resilient | Backup verification probe | Weekly backup probe passes |
| SC-8 | System compounds | KB `reuse_count` trend | Month-over-month increase for 3 consecutive months |

---

## 14. Phased Implementation Plan

### Phase 1: Fix Broken Pipes (Week 1-2)

**Goal:** Session captures reach permanent stores. lessons.md stays at 15 or under.

1. Add `captures.md` and `decisions.md` scaffolds to adf-init
2. Upgrade PreCompact hook from echo to extraction prompt
3. Build classifier script (reads hot buffers, classifies, routes, trims)
4. Add session-end hook to trigger classifier
5. Add 4h launchd job for classifier sweep
6. Run classifier against existing ai-dev lessons.md overflow (34 → 15)
7. Verify: capture something, end session, check it reached KB or Memory

**Exit gate:** SC-2 passing (lessons.md at or below 15 after one week of operation).

### Phase 2: Access + Boundary (Week 3-4)

**Goal:** Unified query works. Boundary enforcement operational.

1. Build `intelligence_query` MCP tool
2. Update /orient to include intelligence_query call
3. Build lint sweep script (contradictions, orphans, staleness, boundary violations)
4. Add weekly lint launchd job
5. Update capture-envelope-standard to v2
6. Verify: SC-1 (orient returns intelligence), SC-5 (lint detects boundary violations)

**Exit gate:** SC-1 and SC-5 passing.

### Phase 3: Stabilize + Measure (Week 5-8)

**Goal:** System runs autonomously. Metrics show compounding.

1. Monitor classifier success rate (false positives, missed routes)
2. Tune classifier prompts based on real data
3. Monitor lint sweep findings, fix recurring issues
4. Measure SC-3 (decision persistence rate)
5. Measure SC-8 (KB reuse trending)
6. Run wiki 2-week assessment (if macmini is back online)

**Exit gate:** All Phase 1+2 success criteria sustained for 4 weeks.

### Phase 4: Multi-Client (Month 3+, deferred)

**Goal:** Non-Claude-Code clients can query intelligence.

1. Build REST adapter over KB + Memory core libraries
2. Deploy on always-on machine
3. Register Codex MCP connection
4. Test ChatGPT custom action (if feasible)
5. Verify: SC-6 (non-Claude-Code access log entries)

**Exit gate:** SC-6 passing.

---

## 15. Open Questions

| # | Question | Status | Resolution Path |
|---|----------|--------|----------------|
| OQ-1 | Can PreCompact hook make MCP tool calls? | Resolved | No — hooks inject text but cannot call MCP tools. Design uses flat-file path (§3.4). |
| OQ-2 | What prompt produces best signal-to-noise for session-end extraction? | Research + iteration | Start with capture-problem.md's proposed prompt, tune based on classifier output quality. |
| OQ-3 | Should classifier run in OrbStack or on host? | Decide at build time | Classifier is a shell script invoking `claude -p`. If it stays shell-only, host is fine. If it needs Python dependencies beyond stdlib, OrbStack. |

---

## 16. Backlog (Deferred)

- **REST/HTTP adapter** — Multi-client access (Phase 4, month 3+)
- **Wiki validation gate** — 2-week assessment when macmini is online
- **KC classifier threshold tuning** — Deferred to Phase 0b (post-observability period)
- **Cross-store dedup** — If lint sweep reveals significant cross-store duplication, build active dedup
- **Memory quality overhaul** — Address 83% low-signal observations if quality filter in lint sweep proves insufficient
- **Capture from non-session sources** — Slack, email, voice notes — future capture sources if hot buffer pattern proves out

---

## 17. Issue Log

| # | Issue | Source | Severity | Complexity | Status | Resolution |
|---|-------|--------|----------|-----------|--------|-----------|
| 1 | PreCompact hook upgrade contradicts session-lifecycle.yaml standard ("Reminder only — no writes") | Internal-C1 | High | Low | Resolved | Added standard update note in §3.4 — standard must be updated before/during Phase 1 |
| 2 | Classifier architecture ambiguous — §12.2 says "Python script" but §3.5 says `claude -p`. How does classifier access MCP tools? | Internal-C1 | High | Medium | Resolved | Clarified in §3.5: shell script invokes `claude -p` which has MCP access via project config. Updated §12.2 table. |
| 3 | Classifier file modifications (removing processed entries) not committed — uncommitted changes could be lost or cause git conflicts | Internal-C1 | High | Low | Resolved | Added git commit step to §3.5 idempotency section |
| 4 | OQ-1 answered in §3.4 body text but still marked "Research needed" in §15 | Internal-C1 | Low | Low | Resolved | Updated OQ-1 status to Resolved |
| 5 | Classifier sweep job needs project discovery mechanism — §6.4 says "across all projects" but no discovery logic specified | Internal-C2 | High | Medium | Resolved | Added project discovery paragraph to §3.5 — find over known code directories |
| 6 | OQ-3 description inconsistent with updated §12.2 component type (said "Python script" after table was changed to "Shell script") | Internal-C2 | Low | Low | Resolved | Updated OQ-3 wording to match |
| — | Internal review complete — 3 cycles, 0 Critical/0 High remaining | Internal-C3 | — | — | Complete | — |
| 7 | Classifier two-phase execution architecture not buildable — interface between classification and routing calls undefined, output schema missing | External-Sonnet | High | Medium | Resolved | Redesigned as single-pass `claude -p` call with MCP access. Added JSON output schema. §3.5 rewritten. |
| 8 | Idempotency claim incorrect — MCP write + file removal not atomic, crash between them creates cold-store duplicates | External-Sonnet | High | Medium | Resolved | Replaced with mark-before-write pattern: mark entries → route → remove marks. Crash at any point is recoverable without duplicates. §3.5 rewritten. |
| 9 | Client project classifier sweep may route confidential learnings to personal KB/Memory | External-Sonnet | — | — | Resolved | Added `.il-exclude` opt-out marker and client boundary note to §3.5 project discovery. Default: include (cross-project learning is the value). |
| — | External review complete — 2 High issues resolved, 1 Develop question addressed | External-Sonnet | — | — | Complete | — |
| 10 | Mark-before-write flow contradicts itself — marks all entries then tries to route "unmarked entries". Also no retry for stuck marks. | External-GPT | High | Medium | Resolved | Replaced with snapshot-and-mark: read unmarked → route → remove successes, mark failures `[pending]` with 3-retry limit. §3.5 rewritten. |
| 11 | No concurrency control between session-end hook and 4h sweep — race on same project creates git conflicts and duplicate writes | External-GPT | High | Medium | Resolved | Added per-project lockfile (`/tmp/il-classifier-{hash}.lock`) with 30-min stale timeout. §3.5 added. |
| 12 | Classifier git commits unscoped — may commit unrelated staged work or fail on dirty index | External-GPT | Medium | Low | Resolved | Specified file-scoped `git add` (only hot buffer files). Skip on merge conflicts. §3.5 added. |
| 13 | MCP access path ambiguous — "global settings" vs "project config" stated in different places | External-GPT | Medium | Low | Resolved | Clarified: global `~/.claude.json` (stdio transports) — works from any directory. §3.5 updated. |
| — | GPT external review complete — 3 High, 1 Medium resolved | External-GPT | — | — | Complete | — |

---

## 18. Develop Handoff

### Design Summary

The Intelligence Layer fixes two broken capture pipes (session capture and lessons.md drain) by separating capture from classification. Agents append to flat-file hot buffers with one decision; an async LLM classifier routes entries to KB or Memory. A three-tier storage model (hot flat files → warm structured files → cold MCP stores) aligns with Karpathy's LLM OS pattern and Claude Code's own memory architecture.

### Key Design Decisions

| Decision | Rationale | Implication for Develop |
|----------|-----------|----------------------|
| Flat-file hot buffers (captures.md, lessons.md, decisions.md) | Git-versioned, zero-friction append, works from hooks | Classifier reads/modifies markdown files, not DB |
| Single-pass `claude -p` classifier with JSON manifest | One LLM call does classification + routing via MCP tools | Needs global MCP config (`~/.claude.json`). Cannot use `--bare` (loses auth/MCP). |
| Snapshot-and-mark idempotency | Prevents cold-store duplicates on crash | Implement `[pending]`/`[failed]` prefixes, 3-retry limit |
| Per-project lockfile for concurrency | Prevents hook/sweep race conditions | `/tmp/il-classifier-{hash}.lock`, 30-min stale timeout |
| Session-end hook + 4h timer (both) | Belt + suspenders — hook for clean exits, timer for crashes | Two trigger paths, same classifier script |
| KB has no content dedup on `send_to_kb` | Designed for URL-based pipeline ingestion, not session captures | Lint sweep (weekly) is the duplicate cleanup mechanism |
| `intelligence_query` as read-only convenience | Unified search across KB + Memory without replacing specific tools | MCP tool addition on KB server, calls both stores |
| `session-lifecycle.yaml` standard must be updated | PreCompact hook changes from reminder-only to extraction prompt | Update standard before or during Phase 1 |

### Capabilities Needed

- Python 3.11+ (existing)
- `claude -p` with Haiku model (existing subscription, global MCP config)
- Claude Code hooks: PreCompact, Stop (existing infrastructure)
- launchd (existing scheduler)
- KB MCP (19 tools, stdio) + Memory MCP (18 tools, stdio) — both local

### Open Questions for Develop

1. **OQ-2:** What prompt produces best signal-to-noise for session-end extraction? Start with `capture-problem.md`'s proposed prompt, tune based on classifier output quality.
2. **OQ-3:** Should classifier script run in OrbStack or on host? Shell-only = host is fine. Python dependencies beyond stdlib = OrbStack.

### Success Criteria (Verify During Implementation)

- [ ] SC-1: `/orient` includes at least one KB + Memory query result when relevant context exists
- [ ] SC-2: lessons.md stays at or below 15 entries per project (sustained over 1 week)
- [ ] SC-3: At least 1 Memory `decision` entry per 5 sessions with non-trivial decisions
- [ ] SC-4: KC + Link Triage >95% success rate (unchanged — verify not degraded)
- [ ] SC-5: No cross-store duplicates in monthly lint sweep
- [ ] SC-7: Weekly backup probe passes
- [ ] SC-8: KB `reuse_count` increases month-over-month for 3 consecutive months

*(SC-6 deferred to Phase 4 — multi-client access)*

### What Was Validated

- Internal review (Opus, 3 cycles): architecture sound, all Brief success criteria addressed, all open questions resolved
- External review (Sonnet): classifier architecture clarified, idempotency mechanism corrected, client boundary added
- External review (GPT): idempotency fully rewritten (snapshot-and-mark), concurrency control added, git scoping specified, MCP access path clarified
- Assumption testing: `--bare` flag busted (loses MCP), Stop hook confirmed viable, KB dedup caveat documented

### Implementation Guidance

**Recommended build order (Phase 1):**
1. Add `captures.md` + `decisions.md` scaffolds to adf-init
2. Upgrade PreCompact hook (echo → extraction prompt)
3. Build classifier script (single-pass `claude -p` + JSON manifest + file updates + git commit)
4. Wire session-end hook to trigger classifier
5. Add 4h launchd job for sweep
6. Run classifier against ai-dev lessons.md overflow (34 → 15)
7. Verify end-to-end: capture → classify → route → cold store

**Edge cases to test:**
- Classifier on empty hot buffers (no entries to process)
- Classifier with `[pending]` entries from prior failed run
- Concurrent hook + sweep (lockfile behavior)
- Hot buffer with merge conflicts (classifier should skip)
- `claude -p` timeout or MCP unreachable (entries should stay unprocessed)

**Reference Documents:**
1. `intent.md` — North star
2. `discover-brief.md` — Full discovery with component inventory
3. `design.md` — This spec
4. `capture-problem.md` — Root cause analysis (at `~/code/_shared/memory/docs/`)
5. `reference-routing.md` — KB/Memory routing rules (at `~/code/_shared/knowledge-base/docs/`)
6. `memory-routing.md` — Memory routing heuristic (at `~/code/_shared/memory/docs/`)
7. `session-lifecycle.yaml` — Session standard to update (at `~/code/_shared/aws/docs/standards/`)

---

## 19. Review Log

| Date | Phase | Reviewer | Findings | Actions |
|------|-------|----------|----------|---------|
| 2026-04-10 | Internal (Phase 1) | Claude Opus | 6 issues (4 High, 2 Low). 3 cycles. All resolved. | Fixed: standard conflict note, classifier architecture clarity, git commit mechanism, project discovery, OQ consistency |
| 2026-04-10 | External (Phase 2a) | Claude Sonnet via `claude -p` | 2 High issues, 1 Develop question. All resolved. | Fixed: single-pass classifier with JSON schema, mark-before-write idempotency, client project boundary |
| 2026-04-10 | External (Phase 2b) | GPT via Codex | 3 High, 1 Medium issues. All resolved. | Fixed: snapshot-and-mark idempotency, concurrency lockfile, scoped git commits, MCP access clarification |

---

## 20. Revision History

| Version | Date | Changes |
|---------|------|---------|
| 0.1.0 | 2026-04-10 | Initial draft — architecture, capture pipeline, access layer, implementation plan |
| 0.2.0 | 2026-04-10 | Internal review complete — 6 issues found and resolved across 3 cycles |
| 0.3.0 | 2026-04-10 | External review (Sonnet) — classifier redesigned (single-pass + JSON schema), idempotency fixed (mark-before-write), client boundary added |
| 0.4.0 | 2026-04-10 | External review (GPT) — idempotency rewritten (snapshot-and-mark with retry), concurrency lockfile, scoped git commits, MCP access clarified |
| 0.5.0 | 2026-04-10 | Assumption testing — `--bare` busted (all refs fixed to `claude -p`), KB dedup caveat added, Stop hook confirmed |
| 1.0.0 | 2026-04-10 | Finalization — Develop Handoff written, design complete |
