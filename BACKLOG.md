# Backlog: Agentic Work System

## Active Items

| ID | Item | Type | Pri | Status |
|----|------|------|-----|--------|
| B1 | Define inter-component communication protocols — how ADF<>Work Mgmt, Krypton<>Work Mgmt, etc. talk to each other | Architecture | P1 | Done |
| B2 | Build governance layer — Krypton governance health check (weekly alignment, drift detection, stale work) | Governance | P1 | Pending |
| B3 | Expand intake/capture beyond Link Triage — route to KB, Memory, backlogs, projects (Krypton `/capture` evolution) | Integration | P1 | Pending |
| B4 | Cross-project observability — operations center with continuous monitoring, tiered alerting, and multi-modal interface (voice/chat, iOS, desktop). Reframed from "dashboard" to "operations center." See `docs/nerve-center-product-brief.md` and `docs/nerve-center-architecture.md`. Likely new ADF project. | Observability | P1 | In Progress |
| B5 | Formalize ring instantiation — how each ring operates at each layer, current vs. target state | Architecture | P2 | Pending |
| B6 | Cross-cutting agent teams (Validation, Review, Improvement) — design and build shared dispatch pattern | Architecture | P2 | Pending |
| B7 | Component integration testing — verify each component pair connects as designed | Quality | P2 | Pending |
| B8 | Operational runbooks — how to use the system day-to-day, common workflows, troubleshooting | Docs | P3 | Pending |
| B9 | Autonomy escalation tracking — measure trust-building per layer, track ratio evolution. Addressed by Nerve Center's Autonomy Assessor monitoring job and decision quality feedback loop. See `docs/nerve-center-architecture.md` §1.1 Jobs. | Governance | P2 | Pending |
| B10 | Enterprise evolution notes — document what would need to change for multi-user/team scale | Architecture | P3 | Pending |
| B11 | Trust boundaries — map trust boundaries for each component and cross-component interactions. Where does trust start/stop? What can each component do autonomously vs. gated? Cascade findings to component-level backlogs where applicable. | Architecture | P1 | Pending |
| B12 | System-to-component design cascade — establish pattern for capturing when system-level designs (e.g., trust boundaries) need implementation at subordinate component level. Prevent system-level decisions from staying abstract. | Governance | P1 | Pending |
| B13 | Review Krypton autonomy gates — understand hook firing frequency (every tool use?), performance impact, necessity. Are PreToolUse/PostToolUse hooks firing on every action? What's the overhead? What does the redaction library do and is it needed? | Review | P1 | Pending |
| B14 | Review data flow patterns 1 & 2 — Pattern 1 (capture → storage via Krypton routing): is this accurate? Link Triage is a primary capture path too. Pattern 2 (focus synthesis): validate the parallel gatherer model. Should there be a Work Mgmt gatherer? | Review | P1 | Pending |
| B15 | Review session protocol enforcement (pattern 4) — how are session start/end instructions actually enforced? Via hooks? CLAUDE.md conventions? What ensures compliance? | Review | P2 | Pending |
| B16 | Deep dive on integration gaps — expand the 6 identified gaps into actionable items with scope, effort, and priority | Architecture | P2 | Pending |
| B17 | Deep dive on MCP server tools — review each server's tool inventory. Work Mgmt 40+ tools seems high. Are they all needed? What's the right tool count? Review KB Manager plugin role vs. KB MCP server. | Review | P2 | Pending |
| B18 | Review model tier mapping in architecture.md — does intent layer truly require Opus minimum? What are we conveying? The gradient (heavier reasoning = higher layers) makes sense but minimum model requirements may be too prescriptive. | Architecture | P2 | Pending |
| B19 | Clarify brief.md scope — articulate the meta-governing purpose: this project ensures alignment and connectivity across all components. Each component self-governs internally; this project governs the whole. How does it handle self-improvement? How does it handle cross-component alignment? | Architecture | P1 | Pending |
| B20 | ADF fifth stage — evaluate "Operate & Improve" as potential fifth stage beyond Deliver. What does ongoing operation and improvement look like within ADF? (Route to ADF project backlog.) | Architecture | P2 | Pending |
| B21 | Architecture diagrams — create visual models at multiple levels: (1) macro system overview, (2) communication protocols / data flows, (3) trust boundaries, (4) component connections. Partially addressed by Nerve Center's desktop companion strategic mode (constellation, topology views). See `docs/nerve-center-architecture.md` §4.2. Static diagram generation still needed separately. | Docs | P1 | Pending |
| B22 | Documentation standard — define a standard documentation structure for every component, with two audiences: (a) user-level docs (layman, end-user) and (b) technical docs (builder, detailed). Design at AWS level, implement at each component level. Cascading item per B12 pattern. | Docs | P1 | Pending |
| B23 | SDK automation spike — build the Drift Detector as the first monitoring job using `claude -p` on Max subscription (zero extra cost). Validates the pattern for all Nerve Center monitoring jobs. Graduation path: if `claude -p` works but needs more programmatic control, evaluate Agent SDK with API credits. Governance health check (B2) becomes the second job. See `docs/nerve-center-architecture.md` §1.1 Jobs and §8 Build Sequence Phase 0. Research captured in KB item `91ed524e`. | Automation | P1 | Pending |
| B24 | Review CC Insights CLAUDE.md recommendations against ADF spec — evaluate 5 suggested conventions (YAML append-only, git auto-commit awareness, config placement, multi-agent stale overwrite prevention, ADF lifecycle enforcement) for inclusion in global/project CLAUDE.md. Must check: size budget, redundancy with existing rules, global vs project scope, ADF spec alignment. Execute via `revise-claude-md` skill. KB items with full details: search "CC Insights convention". Source: CC Insights report 2026-02-12. | Review | Governance | P2 | M | Pending |
| B25 | Review: Try batch backlog with specific IDs pattern — specify backlog item IDs upfront in session prompts for higher goal achievement. Low effort to try, high potential impact. Insight: sessions with specific IDs → fully_achieved; vague starts → partially_achieved. Source: CC Insights report 2026-02-12. | Review | Workflow | P2 | S | Pending |
| B26 | Review: Try task agents for parallel review/audit workflows — spawn sub-agents for review cycles while main session continues implementation. Already have well-defined review processes that could delegate. Source: CC Insights report 2026-02-12. | Review | Workflow | P3 | S | Pending |
| B27 | Review: Evaluate parallel backlog execution feasibility — spawn parallel Claude Code agents per backlog item with coordinator for conflict resolution. Horizon capability requiring reliable multi-agent coordination. Source: CC Insights report 2026-02-12. | Review | Architecture | P3 | M | Pending |
| B28 | Review: Evaluate self-healing CI loop — autonomous test-fix-retest loop with max iterations. Would eliminate babysitting implementation sessions. 13 friction events from buggy code + 12 from wrong approach suggest high value. Source: CC Insights report 2026-02-12. | Review | Automation | P3 | M | Pending |
| B29 | Review: Evaluate autonomous lifecycle orchestrator — orchestrator reads ADF stage defs, dispatches sub-agents per phase, escalates for gate approvals only. End-state vision for the agentic work system. Source: CC Insights report 2026-02-12. | Review | Architecture | P3 | L | Pending |

## Completed

| ID | Item | Date |
|----|------|------|
| B1 | Inter-component communication protocols — `docs/communication-protocols.md` | 2026-02-11 |
