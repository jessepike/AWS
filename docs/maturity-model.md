# Component Maturity Model

## Purpose

Provide a consistent, defensible way to assess the maturity of each component in the agentic work system. Eliminates subjective "feels like Low" ratings that drift out of sync with reality (e.g., WM listed as Design/Low while fully deployed).

**Why this exists:** Session-start audits were taking 30+ minutes because there was no standard to compare against. A scored model makes re-assessment fast and honest.

---

## Five Maturity Levels (CMM-Aligned)

| Level | Name | Description |
|-------|------|-------------|
| L1 | Initial | Exists but ad-hoc. Unpredictable. Manual everything. No consistent process. |
| L2 | Managed | Repeatable. Core functionality works. Intentionally used. Basic documentation. Some integration. |
| L3 | Defined | Standardized. Integrated with other components. Monitored. Regular use in defined workflows. |
| L4 | Measured | Metrics-driven. Health data collected and reviewed. Predictable behavior. Outcomes visible. |
| L5 | Optimizing | Autonomous and self-improving. Self-healing. Evolves based on usage. No manual intervention needed. |

---

## Five Scoring Dimensions

Each dimension is scored 1–5. Total score (5–25) maps to a maturity level.

### 1. Delivery — Is it built and stable?

| Score | Criteria |
|-------|----------|
| 1 | Prototype or incomplete — not reliably usable |
| 2 | MVP delivered and deployed — core functionality works |
| 3 | Feature complete and stable — edge cases handled |
| 4 | Evolved from real usage — versioned, battle-tested |
| 5 | Self-evolving — adapts and improves autonomously |

### 2. Integration — How connected to the rest of the system?

| Score | Criteria |
|-------|----------|
| 1 | Isolated — no connections to other components |
| 2 | One integration point — loosely connected |
| 3 | Multi-integrated — standard interfaces, data flows in both directions |
| 4 | Deep integration — contributes to other components' intelligence; mutual data exchange |
| 5 | First-class citizen — other components depend on it; mutual improvement loops exist |

### 3. Observability — Can you see what it's doing?

| Score | Criteria |
|-------|----------|
| 1 | None — no visibility into behavior or health |
| 2 | Logs exist — basic audit trail |
| 3 | Health checks + alerts — fails are caught proactively |
| 4 | Trend analysis — anomaly detection, patterns surfaced, reports generated |
| 5 | Self-reporting — feeds system-level health; autonomous remediation |

### 4. Documentation — Is it documented for use and maintenance?

| Score | Criteria |
|-------|----------|
| 1 | None |
| 2 | README or basic notes — enough to remember how it works |
| 3 | User docs + technical docs — both audiences covered, architecture documented |
| 4 | Runbooks + decision log — why-decisions captured, examples, troubleshooting guides |
| 5 | Self-documenting — living docs that stay current autonomously |

### 5. Adoption — Is it embedded in real workflows?

| Score | Criteria |
|-------|----------|
| 1 | Not used |
| 2 | Occasional / manual invocation |
| 3 | Regular intentional use — part of defined workflows |
| 4 | Habitual — daily ritual, usage patterns tracked |
| 5 | Autonomous participation — self-activates in appropriate contexts, no prompting needed |

---

## Tier Mapping

| Score Range | Tier |
|-------------|------|
| 5–8 | L1 — Initial |
| 9–13 | L2 — Managed |
| 14–18 | L3 — Defined |
| 19–22 | L4 — Measured |
| 23–25 | L5 — Optimizing |

---

## Component Scorecards

### ADF

| Dimension | Score | Notes |
|-----------|-------|-------|
| Delivery | 4 | Feature complete, multiple stage specs, Operate & Learn spec drafted |
| Integration | 3 | ADF MCP server used across projects; adf-env plugin wired |
| Observability | 3 | adf-env health checks; stage gate enforcement via hooks |
| Documentation | 4 | Stage specs, artifact specs, review prompts, internal review workflow |
| Adoption | 3 | Used as governing framework on every project |
| **Total** | **17** | **L3 — Defined** |

### Knowledge Base

| Dimension | Score | Notes |
|-----------|-------|-------|
| Delivery | 4 | 16 MCP tools, 442 tests, synthesis linking, batch ops |
| Integration | 3 | Krypton gatherer, Link Triage capture, kb-manager plugin |
| Observability | 2 | Health checks open in backlog (KB-11) — not yet built |
| Documentation | 3 | Architecture documented, kb-manager plugin docs |
| Adoption | 3 | Regular use for knowledge storage and retrieval |
| **Total** | **15** | **L3 — Defined** |

### Memory

| Dimension | Score | Notes |
|-----------|-------|-------|
| Delivery | 3 | 14 MCP tools, episodic log, hash-chaining, verify_chain |
| Integration | 2 | Used by Krypton /capture and NC jobs, but adoption thin |
| Observability | 2 | NC runs some memory health checks; not comprehensive |
| Documentation | 2 | Routing guide exists, README covers basics |
| Adoption | 2 | Used but not habitual — 78 NC sessions had zero writes (now partially fixed) |
| **Total** | **11** | **L2 — Managed** |

### Capabilities Registry

| Dimension | Score | Notes |
|-----------|-------|-------|
| Delivery | 2 | INVENTORY.md operational, 71 capabilities, registry spec v1.2 |
| Integration | 1 | Mostly standalone — nothing actively queries it |
| Observability | 1 | None |
| Documentation | 2 | INVENTORY.md serves as the artifact |
| Adoption | 1 | Underutilized — referenced rarely, not in any daily workflow |
| **Total** | **7** | **L1 — Initial** |

### Krypton

| Dimension | Score | Notes |
|-----------|-------|-------|
| Delivery | 3 | 4 commands + /ingest, Slack reporting, WM gatherer, 27 tests |
| Integration | 4 | Connects KB, Memory, ADF, WM — the system's integration hub |
| Observability | 2 | Autonomy gate hooks + audit log; no external monitoring |
| Documentation | 3 | README, command docs, skill docs, capture envelope standard |
| Adoption | 3 | /focus, /capture, /kstatus in regular use; Slack daily/weekly |
| **Total** | **15** | **L3 — Defined** |

### Link Triage

| Dimension | Score | Notes |
|-----------|-------|-------|
| Delivery | 3 | Phase 5 complete, 160 tests, 5 CLI commands, 8-step orchestrator |
| Integration | 2 | Feeds KB capture; otherwise standalone |
| Observability | 1 | No monitoring |
| Documentation | 2 | README covers usage |
| Adoption | 2 | Used when links need processing, not daily |
| **Total** | **10** | **L2 — Managed** |

### Work Management

| Dimension | Score | Notes |
|-----------|-------|-------|
| Delivery | 4 | Full MVP + execution pipeline + WM Manager agent, deployed to Vercel |
| Integration | 3 | Krypton gatherer, ADF connector, Slack alerts |
| Observability | 3 | NC monitors backlog health; execution pipeline tracked |
| Documentation | 2 | API exists; user-facing docs thin |
| Adoption | 3 | WM Manager triage/dispatch, NC daily automation |
| **Total** | **15** | **L3 — Defined** |

### Nerve Center

| Dimension | Score | Notes |
|-----------|-------|-------|
| Delivery | 4 | Phase 0–4 complete — 30+ monitoring jobs, iOS + Slack + Desktop |
| Integration | 4 | Monitors all components, triggers actions, connects all surfaces |
| Observability | 4 | IS the observability layer — Slack alerts, anomaly reporting, trend tracking |
| Documentation | 3 | Architecture docs, phase docs, job inventory |
| Adoption | 4 | 30+ jobs run daily/weekly automatically; daily Slack + iOS in active use |
| **Total** | **19** | **L4 — Measured** |

---

## System-Level Summary

| Component | D | I | O | Doc | A | Total | Tier |
|-----------|---|---|---|-----|---|-------|------|
| ADF | 4 | 3 | 3 | 4 | 3 | 17 | L3 |
| Knowledge Base | 4 | 3 | 2 | 3 | 3 | 15 | L3 |
| Memory | 3 | 2 | 2 | 2 | 2 | 11 | L2 |
| Capabilities Registry | 2 | 1 | 1 | 2 | 1 | 7 | L1 |
| Krypton | 3 | 4 | 2 | 3 | 3 | 15 | L3 |
| Link Triage | 3 | 2 | 1 | 2 | 2 | 10 | L2 |
| Work Management | 4 | 3 | 3 | 2 | 3 | 15 | L3 |
| Nerve Center | 4 | 4 | 4 | 3 | 4 | 19 | L4 |

**System median:** L3 — Defined
**Weakest dimension across system:** Observability (avg 2.3)
**Strongest dimension across system:** Delivery (avg 3.5)

---

## Maintenance

- **Update:** Re-score affected components at session end when significant work is done
- **Full re-score:** Quarterly or after a major release cycle
- **Flag for review:** Any component that drops a tier or stays L1 for 2+ sessions
