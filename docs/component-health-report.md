---
type: "report"
created: "2026-02-23"
scope: "system"
phase: "Phase 1 Audit"
---

# Component Health Report

**Date:** 2026-02-23
**Scope:** All 11 AWS components
**Method:** status.md, BACKLOG.md, jobs.yaml, and launchd plist review
**Purpose:** Honest snapshot — surface every silent failure, establish type + ADF stage for all components.

---

## Summary

| Component | Type | ADF Stage | Artifacts | Backlog | Automation | Silent Failures | Docs |
|-----------|------|-----------|-----------|---------|------------|-----------------|------|
| Agentic Work System | Framework | Operate & Learn | Partial | ✗ Missing | N/A | Stale status.md | Stale |
| ADF | Framework | Develop (Build) | Present | Present | N/A | B87 draft unreviewed | Current |
| Work Management | Product | Develop (post-MVP) | Present | Present | Partial | Auth bypass on API routes | Current |
| Krypton | Product | Operate & Learn | Present | Present | Partial | No job failure alerting | Current |
| Nerve Center | Product | Develop (Phase 4+) | Present | Present | Partial | NC-19 in-progress, auth bypass | Current |
| Knowledge Base | Service | Develop (post-MVP) | Present | Present | ✗ None | No health check (KB-11 pending) | Current |
| Memory Layer | Service | Deliver (v1.1 P4) | Present | Inline | Partial | Probe ≠ functional test | Current |
| Diagram Forge | Service | Deliver (MVP) | Partial | ✗ None | ✗ None | API keys expire silently | Stale |
| Automation Fleet | Operations | N/A | ✗ None | ✗ None | Partial | Most job failures silent | ✗ None |
| Link Triage Pipeline | Operations | Develop (Phase 5) | Present | ✗ None | ✗ None | No schedule, no alerts | Stale |
| Capabilities Registry | Reference | Develop | Present | Present | ✗ None | INVENTORY.md 11 days stale | Stale |

**Overall:** Operational core is running but the observability ring has major gaps. Silent failures are widespread in the automation layer.

---

## Component Details

### 1. Agentic Work System

**Type:** Framework
**ADF Stage:** Operate & Learn (docs say "Operate & Evolve" — non-standard terminology)

**Artifact Presence:**
- ✓ architecture.md (v1.0.0, 2026-02-09, status: "draft")
- ✓ docs/status.md (updated 2026-02-11 — **12 days stale**)
- ✓ BACKLOG.md (28 active items, only B1 completed)
- ✗ No decision log (open questions in architecture.md, not tracked)
- ✗ No README for users

**Backlog Health:** 28 active items, 1 completed. Mix of open architecture reviews (B13-B29 from CC Insights) and genuine system work (B2-B12). Many items are aspirational/review types. Backlog has not been pruned since ~2026-02-12.

**Automation Health:** Framework — no automation needed directly. Nerve Center + WM jobs monitor the system components.

**Silent Failures:**
- **status.md 12 days stale.** Component Maturity table is wrong: WM listed as "Design" (it's post-MVP Develop), Link Triage listed as "low maturity" (3+ weeks operational), Nerve Center absent entirely.
- **architecture.md "Installed Jobs" table lists 6 jobs.** Reality: 28+ jobs across Krypton, WM, and NC. Major drift.
- **"draft" status on architecture.md** — the governing reference document has been "draft" since 2026-02-09.

**Docs Accuracy:** Stale. architecture.md core model is sound but operational sections drift.

**WM Items Filed:** `e962b9a4` (status.md update), `bc17ba5c` (architecture.md job table)

---

### 2. ADF (Agentic Development Framework)

**Type:** Framework
**ADF Stage:** Develop — Build phase (framework quality improvements)

**Artifact Presence:**
- ✓ status.md (updated 2026-02-23, current)
- ✓ BACKLOG.md (27 active items in WM, 5 P1)
- ✓ Extensive spec files (ADF-ARCHITECTURE-SPEC, ADF-PLANNING-SPEC, ADF-STAGES-SPEC, etc.)
- ✓ Session log maintained
- ✗ No formal decision log (decisions embedded in specs)
- ✗ ADF-OPERATE-SPEC.md drafted but not reviewed or integrated

**Backlog Health:** 27 active items, well-maintained. B87 (Operate & Learn spec) drafted today but needs review.

**Automation Health:** Framework — no direct automation. adf-env plugin handles per-project governance checks.

**Silent Failures:**
- **B87 ADF-OPERATE-SPEC.md v0.1.0** drafted 2026-02-23 but not reviewed or integrated into ADF-STAGES-SPEC.md. If sessions start citing "Operate & Learn" stage, the spec is the authority — it needs to be reviewed and promoted before it's operationally relied upon.

**Docs Accuracy:** Good. status.md current. Specs actively maintained.

**WM Items Filed:** `61b04c4d` (B87 review and promotion)

---

### 3. Work Management

**Type:** Product
**ADF Stage:** Develop — post-MVP, active enhancement

**Artifact Presence:**
- ✓ status.md (updated 2026-02-20)
- ✓ BACKLOG.md (112 active items in WM — P1:69, P2:40, P3:3)
- ✓ design docs (architecture, data model, interface)
- ✓ intent.md, discover-brief.md

**Backlog Health:** 112 active items is high. Many are wave 1-3 items that may already be complete (status says "Completed" for multiple waves). Backlog needs pruning — completed waves should be moved to archive.

**Automation Health:**
- ✓ 5 launchd jobs deployed (adf-sync, triage-login, triage-light, triage-deep, briefing)
- ✓ Execution runner + execution monitor scripts
- ✓ WM_SLACK_WEBHOOK_URL for execution fail/timeout alerts
- ✗ No job-level exit-code failure alerting for launchd jobs

**Silent Failures:**
- **Auth bypass on NC API routes** (confirmed 2026-02-23 in MCP memory): unauthenticated POSTs to `/api/jobs/:id/run` and `/api/triage/decisions/:id/{approve|reject}` reach backend and return domain 404s. API handlers don't enforce session checks independently.
- **112 backlog items** — high number, many stale. "Pending_decisions" list is also stale (6 decisions carried from Discover that were already resolved in Design).

**Docs Accuracy:** status.md current. BACKLOG.md overloaded with completed items.

**WM Items Filed:** `951ab3d7` (auth bypass on NC API routes)

---

### 4. Krypton

**Type:** Product
**ADF Stage:** Operate & Learn (v0.1.0 delivered 2026-02-11)

**Artifact Presence:**
- ✓ status.md (updated 2026-02-19)
- ✓ BACKLOG.md (37 active items in WM, 13 P1)
- ✓ README
- ✓ intent.md
- ✗ No decision log

**Backlog Health:** 37 active items, 13 P1. Includes carry-over items (B24, B25 — /batch-backlog from early Operate sessions). Several completed items still in status.md "Next Steps" as unchecked. Needs pruning.

**Automation Health:**
- ✓ 9 launchd plists deployed (daily, weekly, backlog-aging, git-hygiene, kb-curation, mcp-health, memory-audit, memory-maintenance, insights.nightly)
- ✓ NC Slack reporting (daily 5am, weekly Mon 4am)
- ✓ Krypton-chat on Railway for Slack intelligence
- **✗ ZERO job failure alerting on any launchd job.** Jobs post to Slack on success, fail silently.

**Silent Failures:**
- **No failure alerting on 9 launchd jobs.** If com.claude.krypton.daily exits non-zero, nothing fires.
- **Krypton-chat is Slack-only** — no MCP servers, no KB/Memory/ADF access. It's synthetic intelligence based on NC data only (health + findings). Not the "real Krypton."
- **status.md 4 days stale.** Completed items (Always-on Slack chat) still showing as open next step items with checkbox notation.

**Docs Accuracy:** status.md mostly current. Minor drift on Next Steps section.

**WM Items Filed:** `06ceca25` (job failure alerting — in WO-01)

---

### 5. Nerve Center

**Type:** Product
**ADF Stage:** Develop — Phase 4 Desktop complete; active enhancement

**Artifact Presence:**
- ✓ status.md (updated 2026-02-19, very detailed)
- ✓ BACKLOG.md (active: 20+ items)
- ✓ Design docs (architecture, data model, interface, capabilities)
- ✓ intent.md, discover-brief.md
- ✓ ADF planning artifacts for each phase

**Backlog Health:** Well-maintained. NC-22.2 (Suggestions phase) in-progress. Several NC-7/11 items deferred to P3 correctly. NC-36 (Memory Layer usage log) is a P1 monitoring gap.

**Automation Health:**
- ✓ 13 jobs in jobs.yaml running on Railway
- ✓ RED/YELLOW Slack alerting for findings
- ✓ Scheduler with retry-once policy
- ✓ Deduplication via fingerprinting (NC-20 done)
- ✓ Notification delivery verification (NC-30 done)
- ✗ NC-19 (Slack command validation) still "In Progress" — unclear if /nc run, /nc silence, action buttons actually work

**Silent Failures:**
- **NC-19 in-progress** — Slack action buttons and `/nc run`, `/nc silence` commands not fully validated.
- **Auth bypass** (see WM item `951ab3d7`) — same Next.js API issue applies.
- **549/561 findings were noise** (fixed 2026-02-18) — root cause was broken Railway jobs, not a current issue, but the pattern (noise overwhelming signal) could recur.

**Docs Accuracy:** status.md is comprehensive and current to 2026-02-19.

**WM Items Filed:** `951ab3d7` (auth bypass — covers NC)

---

### 6. Knowledge Base

**Type:** Service
**ADF Stage:** Develop — post-MVP enhancements (6 phases complete, 408 tests)

**Artifact Presence:**
- ✓ status.md (updated 2026-02-23, current)
- ✓ BACKLOG.md (v1.4, 36 items: 17 done, 19 pending)
- ✓ design.md, architecture docs
- ✓ intent.md, discover-brief.md

**Backlog Health:** 25 items in WM (P1:1, P2:18, P3:6). KB-11 (health checks) is the critical P1 gap. Well-maintained.

**Automation Health:**
- ✓ NC mcp-availability probes MCP servers every 15 min
- ✓ NC knowledge-auditor (weekly) runs against docs
- **✗ No functional health check** — mcp-availability checks connectivity, not KB functionality (search, write, retrieval)
- **✗ KB-11 (health checks) in backlog but not implemented**

**Silent Failures:**
- **No health check that fires on KB service degradation.** If the vector store becomes corrupted, search returns empty, or write_to_kb fails — nothing alerts. Krypton, NC, and ADF agents all depend on KB. Silent KB failure = silent Krypton degradation.

**Docs Accuracy:** status.md current. BACKLOG.md well-maintained.

**WM Items Filed:** `c32ffc92` (KB health check)

---

### 7. Memory Layer

**Type:** Service
**ADF Stage:** Deliver — v1.1 Phase 4 (measurement period, started 2026-02-19)

**Artifact Presence:**
- ✓ status.md (updated 2026-02-23, current)
- ✓ docs/ (design, usage, capture governance)
- ✓ ADF Deliver stage artifacts present
- Backlog: tracked inline in status.md (mostly completed)

**Backlog Health:** Most post-MVP items completed. One open item: Hybrid search (FTS5/BM25). No formal BACKLOG.md but status.md tracks items clearly.

**Automation Health:**
- ✓ NC mcp-availability probes every 15 min
- ✓ SessionStart hook (daily_check.py) surfaces memory capture stats
- ✓ /handoff skill + SessionEnd hook for capture
- ✓ Track 1 fix: write_memory added to 5 NC job prompts (2026-02-20)
- **✗ mcp-availability probes connectivity, not functional memory reads/writes**
- **✗ No alerting if memory write failure rate spikes**

**Silent Failures:**
- **Error rate monitoring gap.** Usage log (data/usage.jsonl) captures all calls including errors. Error rate was 13.8% before cleanup (2026-02-23), now 0.6% after purging demo entries. But there's no automated alerting if error rate spikes again. NC-36 tracks this as P1 pending.
- **NC-36 (Memory Layer usage log consumption)** is P1 pending in NC backlog — "nothing consumes it" is accurate.

**Docs Accuracy:** status.md current. Well-maintained.

**WM Items Filed:** None new — NC-36 already captures the monitoring gap.

---

### 8. Diagram Forge

**Type:** Service
**ADF Stage:** Deliver — MVP complete (initial release)

**Artifact Presence:**
- ✓ docs/status.md (but no ADF frontmatter)
- ✓ README with architecture section
- ✓ intent.md, design.md
- **✗ No BACKLOG.md** — "Next Steps" list in status.md is not a tracked backlog
- **✗ No decision log**
- **✗ status.md lacks ADF frontmatter** (project/stage/updated fields)

**Backlog Health:** No formal backlog. "Next Steps" in status.md includes: model/key management system, sample diagram images, PyPI publish, end-to-end provider testing, cross-client testing. None triaged or prioritized.

**Automation Health:**
- ✗ No health check
- ✗ No monitoring job
- ✗ No failure alerting for provider API key expiry

**Silent Failures:**
- **API keys can expire silently.** Confirmed: NC session 7 (2026-02-13) all providers failed with expired API keys — discovered manually when generating a diagram.
- **No functional testing** of providers after key changes.

**Docs Accuracy:** Stale. status.md says "MVP Complete — Initial Release" but doesn't reflect current operational state (keys are configured, providers tested). No refresh date tracking.

**WM Items Filed:** `4dcdce88` (Diagram Forge health check), `8f6ec7b5` (ADF-standard artifacts)

---

### 9. Automation Fleet

**Type:** Operations
**ADF Stage:** N/A (operational layer, not a project)

**Artifact Presence:**
- **✗ No dedicated status.md**
- **✗ No canonical job registry document**
- **✗ No BACKLOG.md**
- ✓ Distributed: NC jobs.yaml (13 jobs), launchd plists (15 jobs), WM execution scripts (~3 jobs)

**Fleet Inventory (confirmed):**

| Category | Count | Source |
|----------|-------|--------|
| NC scheduler (Railway) | 13 | nerve-center/config/jobs.yaml |
| Krypton launchd | 9 | ~/Library/LaunchAgents/com.claude.krypton.* |
| WM launchd | 5 | ~/Library/LaunchAgents/com.claude.wm.* |
| insights.nightly | 1 | ~/Library/LaunchAgents/com.claude.insights.nightly.plist |
| WM execution scripts | ~3 | scripts/execution-runner, execution-monitor, execution-briefing |
| **Total confirmed** | **~31** | — |
| **Plan target** | 35 | — |
| **Gap** | ~4 | token-watchdog + unknown |

**Automation Health:**
- ✓ NC jobs: 13 jobs with RED/YELLOW alerting for findings
- ✓ WM execution: failure/timeout Slack alerts via WM_SLACK_WEBHOOK_URL
- **✗ Krypton launchd: ZERO failure alerting on all 9 jobs**
- **✗ WM launchd: no exit-code failure alerting (separate from execution monitor)**
- **✗ No canonical job registry** — can't audit coverage without inventory

**Silent Failures:**
- **The biggest silent failure in the system.** 9 Krypton launchd jobs run without any failure alerting. If they fail (bad token, API error, script bug), nothing fires. This has happened: 78 NC sessions with zero memory writes went undetected.

**WM Items Filed:** `7560c7c6` (canonical job registry), `06ceca25` (job failure alerting)

---

### 10. Link Triage Pipeline

**Type:** Operations
**ADF Stage:** Develop — Phase 5 complete, ready for Deliver

**Artifact Presence:**
- ✓ status.md (updated 2026-02-06 — **17 days stale**)
- ✓ Design docs (design.md with develop handoff)
- **✗ No BACKLOG.md** (glob returned no match)
- ✓ /pipeline skill for manual operation

**Backlog Health:** No BACKLOG.md. The 6 Deliver-stage tasks (deployment, monitoring, optimization) are mentioned in status.md Phase 5 handoff but not tracked anywhere.

**Automation Health:**
- ✓ /pipeline skill exists for manual triggering
- **✗ No automated launchd schedule**
- **✗ No failure alerting**
- **✗ No monitoring coverage** in NC jobs

**Silent Failures:**
- **No automation = invisible operation.** Pipeline runs only when remembered. No way to know if last run succeeded. No history of run frequency.
- **Deliver stage incomplete.** Phase 5 handoff says "6 tasks in Deliver stage (deployment, monitoring, optimization)" — none done.
- **Status.md 17 days stale.** State unclear: is it running? when was last run?

**Docs Accuracy:** Stale (17 days). Does not reflect operational reality.

**WM Items Filed:** `dd708253` (formalize operational status)

---

### 11. Capabilities Registry

**Type:** Reference
**ADF Stage:** Develop (schema updates, client audit in progress)

**Artifact Presence:**
- ✓ INVENTORY.md (auto-generated, last run 2026-02-12 — **11 days stale**)
- ✓ status.md (updated 2026-02-12)
- ✓ BACKLOG.md (11 active items in WM: CR-2, CR-4–9)
- ✓ REGISTRY-SPEC.md (v1.3.0)
- ✓ Scripts: sync, promote, generate-inventory, check-freshness

**Backlog Health:** 11 WM items (4 P1, 6 P2, 1 P3). CR-1 (agents deep dive) done. CR-6 (client audit) done. CR-2 (skills catalog leverage), CR-7/8 (prune low-use skills, quality=0 stubs) open.

**Automation Health:**
- ✓ check-freshness script exists
- **✗ No automated refresh of INVENTORY.md**
- **✗ No scheduled job to detect drift between capabilities/*.yaml and INVENTORY.md**
- **✗ INVENTORY.md 11 days stale**

**Silent Failures:**
- **INVENTORY.md drift.** If capabilities are added/removed without running generate-inventory.sh, the ADF MCP server serves stale data. ADF agents use `query_capabilities` to discover what's available — stale INVENTORY.md means stale discovery.
- **72 capabilities in INVENTORY.md** (generated 2026-02-12). Several capabilities may have been added since.

**Docs Accuracy:** Stale. INVENTORY.md 11 days old.

**WM Items Filed:** `be4bba12` (INVENTORY.md refresh mechanism)

---

## Confirmed Silent Failures (Priority Ordered)

| # | Gap | Component | Severity | WM Item |
|---|-----|-----------|----------|---------|
| 1 | 9 Krypton launchd jobs with no failure alerting | Automation Fleet / Krypton | P1 | `06ceca25` |
| 2 | No canonical job registry (can't audit fleet without inventory) | Automation Fleet | P1 | `7560c7c6` |
| 3 | NC API auth bypass — unauthenticated API calls reach backend | Nerve Center / WM | P1 | `951ab3d7` |
| 4 | No KB health check — service degradation is invisible | Knowledge Base | P1 | `c32ffc92` |
| 5 | Diagram Forge API keys expire silently | Diagram Forge | P1 | `4dcdce88` |
| 6 | Link Triage has no automation, no schedule, no failure alerting | Link Triage Pipeline | P2 | `dd708253` |
| 7 | INVENTORY.md 11 days stale, no auto-refresh | Capabilities Registry | P2 | `be4bba12` |
| 8 | AWS status.md 12 days stale, Component Maturity wrong | Agentic Work System | P2 | `e962b9a4` |
| 9 | NC Memory Layer usage log not consumed, error rate not monitored | Memory Layer | P1 | NC-36 |
| 10 | ADF B87 spec drafted but unreviewed, not integrated | ADF | P2 | `61b04c4d` |

---

## Phase 2 Priorities (Floor Raise)

Based on this audit, the Phase 2 floor raise should execute in this order:

**Track 1: Job failure alerting (highest impact)**
- Add exit-code failure alerting to all 9 Krypton launchd jobs (WO-01 `06ceca25`)
- Build canonical job registry (WO-01 `7560c7c6`)

**Track 2: Service health checks**
- Wire KB to NC health monitoring (KB `c32ffc92`)
- Add Diagram Forge provider health probe (Business Ops `4dcdce88`)
- Verify Memory Layer NC probe tests functionality, not just connectivity

**Track 3: Security**
- Fix NC API auth bypass (Business Ops `951ab3d7`)

**Track 4: Backlog pruning**
- WM: archive completed waves (100+ items that are already done)
- Krypton: close completed "Next Steps" items
- AWS BACKLOG: close B4 (Nerve Center is "In Progress" — update status)

**Track 5: Reference accuracy**
- Refresh Capabilities Registry INVENTORY.md (`be4bba12`)
- Update AWS status.md Component Maturity table (`e962b9a4`)
- Update AWS architecture.md job table (`bc17ba5c`)

---

## WM Backlog Items Filed (This Session)

| WM ID | Title | Project | Priority |
|-------|-------|---------|----------|
| `7560c7c6` | Canonical job registry | WO-01 | P1 |
| `06ceca25` | Job failure alerting — Krypton launchd fleet | WO-01 | P1 |
| `c32ffc92` | KB-11 health check — NC monitoring | Knowledge Base | P1 |
| `4dcdce88` | Diagram Forge health check | Business Ops | P1 |
| `951ab3d7` | NC API auth bypass | Business Ops | P1 |
| `e962b9a4` | AWS status.md stale update | Business Ops | P2 |
| `bc17ba5c` | AWS architecture.md job table | Business Ops | P2 |
| `dd708253` | Link Triage operational status | Business Ops | P2 |
| `be4bba12` | Capabilities Registry refresh mechanism | Capabilities Registry | P2 |
| `8f6ec7b5` | Diagram Forge ADF-standard artifacts | Business Ops | P3 |
| `61b04c4d` | B87 ADF Operate & Learn spec review | ADF | P2 |
