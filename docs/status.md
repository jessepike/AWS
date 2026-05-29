---
updated: 2026-05-27
stage: operate
---

# Status: Agentic Work System

## 2026-05-27 — R7 ratified + Agent-Canvas convention live

Two parallel arcs closed in one session.

**Agent-Canvas Collaboration Convention** — encoded and live for every Claude-side session. Review-gated artifacts (ADRs, designs, plans, ratifications) go to agent-canvas as HTML + decision-set; agent ends turn after dispatch; manager picks up `get_user_messages`/`get_comments` on next invocation (headless operators never block). Ships as `~/.claude/rules/agent-canvas-collab.md` (auto-loads) + lean "Review Surfaces" pointer in global `CLAUDE.md` + shared HTML template `capabilities-registry/templates/agent-canvas-review.html` (`bb3f7d7`) + cross-runtime awareness pointer in `~/.codex/AGENTS.md`. Dogfooded on its own proposal as the first artifact through the pipe (Jesse-approved via decision-set 2026-05-26).

**ADR-007 R7 ratified** via canvas decision-set (`ownership-rubric-r7-2026-05-27-b`). All 7 decisions on the recommended path: distributed-PM model approved (Krypton = operating substrate, Forge = dev-system, CTO = infra); **PMO = B+A** (Krypton-held function, no new agent → also settles R8); **NC + Pike Dashboard → CTO**; **Work Management → Krypton**; **KB + Memory + Knowledge Capture → Krypton**; **Diagram Forge → Forge**; **AWS owner = Krypton + write_authority = Forge**. Recorded: rubric `ratified` (`c0d5621`), ADR-007 second Addendum (`7ce983f`), portfolio-map resolver + Part A rows updated (`aebd86f`, Krypton-pushed per cross-owner protocol).

**Self-inflicted wrinkle — caught + corrected.** The R7 Forge run hit `API ConnectionRefused` at the end (after the aws commits landed). Forge had also drafted a pike-agents CHANGELOG entry asserting that a canvas-MCP self-healing shim shipped — verification showed no shim file was ever modified (phantom claim), and the live rule briefly leaned on the false premise. Corrective Forge run (`f78b83a`) rewrote the rule's fallback to truth (*"retry once, then fall back; there is currently no auto-reconnect layer — nothing self-heals a dropped connection"*) and backlogged the real shim work as **FORGE-P2-CANVAS-HARDEN** (owner Tools). Trees clean.

**Carrying:** canvas-MCP reliability diagnosis → Tools (3 drops in-session); shim auto-reconnect → FORGE-P2-CANVAS-HARDEN; R3/R6 enforcement wiring still independent / ready to build; Phase 2b parked; v2-harness model-forcing (P2) still open.

---

## 2026-05-25 — Per-project contract pilot program COMPLETE + ADR-007 fold-in (R10)

The R10 pilot program is **done**. All 3 pilots ran clean and are pushed:
capabilities-registry (`de2cb06`), aws (`fe5ee38`), krypton (`4aef49d`); R5
resolver rows published (`2c69e2a`, `4fa7710`, inline). Forge folded the proven
findings into the standard and the decision ledger:

- **ADR-007 amended** (`3522ea7`) with a post-pilot Addendum — R10 complete; records
  the two clarifications, reconciles the v1.2.0 "deferred" drift (it had shipped), and
  formally records the manager tool-boundary as **SOFT/monitored** (Phase 2b contingent),
  resolving the trivial-change carve-out contradiction.
- **`project-layout.yaml` → v1.2.1** (`3dff1f9`): (1) **R3 restated shape-agnostically** —
  a decision ledger exists and is active, satisfied by root `decisions.md`,
  `docs/decisions.md`, OR `docs/decisions/` (the 3 pilots produced all 3 shapes);
  `docs/decisions.md` added to `alt_paths`. (2) **R2 multi-CLAUDE.md guidance** — when
  >1 CLAUDE.md, exactly one imports `@AGENTS.md`, others are thin non-importing pointers.
- **contract-pilot-plan.md → COMPLETE** with the outcome table.

**Ratified model unchanged** — manager/operator, the 7 org decisions, and R1–R10
semantics all stand. These were wording clarifications + drift reconciliation only.
Conformance only broadened (krypton's `docs/decisions.md` now matches cleanly); no
previously-conformant project regressed.

## 2026-05-25 — Per-project contract Pilot #3 (aws — reflexivity test)

Forge applied the ADR-007 per-project contract to aws itself (the governance
project consuming its own standard). Shipped: `AGENTS.md` (canonical context
source), both `CLAUDE.md` files converted to `owner: forge` + thin overlays,
R5 resolver entry in `docs/active/portfolio-map.md`. Two interpretation calls
(recorded in `AGENTS.md` § Contract conformance): (1) `docs/decisions/` satisfies
R3 — no root `decisions.md` added; (2) dual `CLAUDE.md` resolved as root=importer,
`.claude/`=non-importing pointer, to avoid double-loading `AGENTS.md`. Contract
described aws cleanly; one MINOR brittleness flagged (R2 assumes a single
`CLAUDE.md`). status.md was already fresh; no content refresh needed.

## Handoff — 2026-05-25
**From:** Krypton (Opus) — org-model design + foundation session
**To:** Krypton (fresh) — pilot execution
**Context:** Agent org model ratified (ADR-007); Phase 1 + 2a landed + pushed; substrate-4 repos on GitHub private. Manager tool-boundary is SOFT/monitored, Phase 2b contingent. All trees clean, all session work pushed.
**Next actions:**
1. Confirm the 3 pilots (capabilities-registry → aws → krypton); run **pilot #1** — add AGENTS.md + contract conformance to capabilities-registry (dispatch headless Forge).
2. Optional Forge: ADR-007 soft-constraint footnote + manager-overreach monitor hook.
3. Remaining no-origin repos (knowledge-capture, sources, personal-wiki, clients/*, sandbox/*) — set remotes only after per-repo privacy/secret review.
**Key files:**
- `docs/active/agent-org-charter.md` (+ `.html`) — the ratified org model
- `docs/decisions/ADR-007*` — model + 7 decisions + contract R1–R10
- `docs/active/contract-pilot-plan.md` — pilot sequence
- `~/.claude/state/krypton.md` — Krypton continuity state
**Model recommendation:** `claude-krypton` (Opus) to orchestrate + dispatch headless Forge for the pilot. **Fresh, not fork** — this session's context is exhausted; artifacts carry it.

---

## 2026-05-25 — Agent Org Model ratified + foundation landed

**Shipped (all committed; aws + pike-agents + capabilities-registry + krypton + nerve-center pushed to remote):**
- **Agent Org Charter ratified** — manager/operator model, continuity-ownership model, functional owners. `docs/active/agent-org-charter.md` (+ HTML surface for Agent Canvas review).
- **ADR-007** — manager/operator model + 7 ratified org decisions + per-project contract R1–R10; reconciles AGENTS.md-canonical (R2).
- **jobs-agent created** — functional owner of all scheduled jobs; Nerve Center = the observability/control product it operates through. **wm-agent latent owner-face** formalized (deterministic runtime + latent owner).
- **il-classifier token leak fixed** (self-heal matcher) · de-drift sweep (VERSION 1.0.0→1.3.0) · 11-repo stale-symlink ref cleanup · marketplace.json refresh · jobs-agent `.zshrc` launcher.

**7 ratified org decisions:** infra split (Krypton = knowledge substrate / CTO = compute) · wm-agent owns the WM spine · jobs-agent + NC-as-product · Forge peer-to-CTO · CTO pure orchestrator (tool-boundary = guardrail) · trivial-change threshold (≤15 lines / 1 file / reversible / own-domain) · Krypton owns the charter.

**Phase 2a DONE + pushed:** default-to-delegate instruction on all 7 managers + `project-layout.yaml` v1.2.0 (AGENTS.md canonical, R1–R10) + contract pilot plan. **Decision (Jesse):** manager tool-boundary is a **SOFT constraint** — managers retain Write/Edit/Bash, are *instructed* to delegate by default, **monitored**. **Phase 2b (hard tool-removal) is downgraded to contingent** — revisited only if monitoring shows over-implementation. Resolves the contradiction with the trivial-change carve-out.

**Open infra flags:** no-origin repos (`agent-exec`, `knowledge-base`, `wm-agent`, `pike-dashboard` +) can't push — need remotes set; `even-ground` / `vet-books` need rebase. v2 harness forces Opus on all agents regardless of frontmatter `model:` (jobs-agent runs Opus, not its Sonnet class).

**Next entry point:** approve the 3 pilots (capabilities-registry → aws → krypton) → run **pilot #1** (add AGENTS.md + contract conformance to capabilities-registry) · set remotes on no-origin repos (agent-exec, knowledge-base, wm-agent, pike-dashboard) · optional manager-overreach monitor hook (Forge) · ADR-007 soft-constraint footnote (next Forge run).

**References:** `docs/active/agent-org-charter.md`, `docs/decisions/ADR-007*`, `docs/active/per-project-contract-proposal.md`, `docs/inbox/2026-05-24-brain-dump.md`

---

## 2026-04-10 — AWS Governance Sprint Day 2

**Maturity:** 6/10 → 7/10 operational

**Shipped:**
- `/project-doctor` skill (SKILL.md + standards-checklist + 5 templates + capability.yaml, 113 capabilities total)
- `workflow-change-detector` UserPromptSubmit hook — live in production, 8 trigger patterns, non-blocking
- `project-layout.yaml` v1.1.0: added `alt_paths: [docs/intent.md]` (standard was wrong, not the projects)
- Portfolio baseline audit: 18 projects, 583-line report at `docs/active/baseline-audit-2026-04-09.md`
- Bulk conformance fix: 13 files created, 5 modified, 10 docs/active/ dirs across 11 Forge-owned projects
- Client template extraction plan at `docs/active/client-template-extraction-plan.md` (Q3 recommendation)
- Intelligence Layer Phase 1 workspace pieces: `scripts/il-classifier.sh` and `session-lifecycle.yaml` v1.1.0 (pre-compact extraction prompt + async hot-buffer classifier)

**Post-fix portfolio:** 1 clean / 7 minor / 3 moderate / 0 major (was 7 major). 7 critical skipped (client/bare repos).

**Next session entry point:** Verify `il-classifier.sh` against live `claude -p` output shape, route the blocked adf-init + hook-path changes through Forge, then continue with overnight hygiene verification, project-doctor re-run, CLAUDE.md trims, hook pattern tuning, and registry health.

**References:** `docs/decisions/ADR-001.md`, `docs/active/baseline-audit-2026-04-09.md`, `CHANGELOG.md`

---

## 2026-04-09 — AWS Governance Sprint Day 1

**Maturity:** 5/10 → 6/10 structural

**Shipped:**
- ADR-001: AWS governance activation (decisions framework stood up)
- 4 standards YAMLs: `docs/standards/` (project-layout, claude-md, model-routing, agent-authority)
- Directory rename: `agentic-work-system/` → `aws/` (canonical path is now `_shared/aws/`)
- ADF specs folded into `docs/specs/adf/` (symlink at `_shared/adf/` → `_shared/aws/docs/specs/adf/`)
- Global CLAUDE.md: AWS Governance section added + Forge exclusive write-authority rule
- Forge agent registered in capabilities-registry
- ai-dev CLAUDE.md cleaned to ≤30 lines
- ai-dev legacy ADF specs archived
- 7 downstream HARD path references updated to new canonical paths

**Safety net:** Symlinks in place at `_shared/agentic-work-system` and `_shared/adf` (old paths). These are temporary — targeted for removal in 3-7 days after no breakage observed. Removal tracked in BACKLOG.md.

**Next session entry point (Day 2):** Build `/project-doctor` skill, `workflow-change-detector`, and `baseline-audit.sh`. Run manual baseline audit across all projects.

**References:** `docs/decisions/ADR-001.md`, `docs/active/aws-governance-sprint-handoff.md`

---

## Current Stage: Operate & Evolve

All major MVPs have been delivered. The system is entering integration and tuning phase.

## Component Maturity

Scored across 5 dimensions (Delivery, Integration, Observability, Documentation, Adoption) — each 1–5.
Full rubric: `docs/maturity-model.md`

| Component | D | I | O | Doc | A | Score | Tier |
|-----------|---|---|---|-----|---|-------|------|
| ADF | 4 | 3 | 3 | 4 | 3 | 17 | L3 — Defined |
| Knowledge Base | 4 | 3 | 3 | 3 | 3 | 16 | L3 — Defined |
| Memory | 3 | 2 | 3 | 2 | 2 | 12 | L2 — Managed |
| Capabilities Registry | 2 | 1 | 1 | 2 | 1 | 7 | L1 — Initial |
| Krypton | 3 | 4 | 2 | 3 | 3 | 15 | L3 — Defined |
| Link Triage | 3 | 2 | 1 | 2 | 2 | 10 | L2 — Managed |
| Work Management | 4 | 3 | 3 | 2 | 3 | 15 | L3 — Defined |
| Nerve Center | 4 | 4 | 4 | 3 | 4 | 19 | L4 — Measured |

**System median:** L3 | **Weakest:** Observability (avg 2.5, improving) | **Strongest:** Delivery (avg 3.5)

## Embedding Queue

Newly created artifacts that exist but aren't yet embedded in regular workflows. Review at each session start — remove when "embedded" criteria is met, or escalate to a backlog item if integration work is needed.

| Artifact | Created | Broader Applicability | Embedded When | Status |
|----------|---------|----------------------|---------------|--------|
| `docs/maturity-model.md` — 5-level CMM-aligned scoring rubric | 2026-02-24 | Applicable beyond AWS: any project, tool, or capability can be scored. Could become a system-wide standard. | Scores updated at least twice; referenced in session briefs without prompting; other projects adopt or adapt it | Incubating |
| Why/Realized fields — ADF spec v1.1.0 | 2026-02-24 | System-wide standard. Could cascade to other projects not yet in AWS scope. | WM schema migration complete (tracked: WM aee4013c) | Graduated — markdown cascade done; WM DB migration pending |

## Last Session

- **Date:** 2026-04-09
- **What happened:** Cross-project audit + CMM maturity model + Why/Realized cascade to all 8 components. Closed B3, B20, B30. ADF spec v1.1.0 shipped.
- **Key insight:** Built broadly, not linearly — new artifacts need an active embedding phase or they drift into orphaned docs. Embedding Queue is the mechanism.

## Session Log

| Date | Summary |
|------|---------|
| 2026-04-11 | Added `scripts/il-lint-sweep.sh`, a weekly Intelligence Layer health-check script covering contradictions, staleness, hot-buffer overflow, boundary violations, and orphaned KB captures with markdown report output under `~/.logs/`. |
| 2026-04-10 | Intelligence Layer Phase 1 (workspace-local): added async hot-buffer classifier script with sweep/lock/pending handling; updated session lifecycle standard so pre-compact becomes an extraction prompt rather than a reminder-only hook. |
| 2026-04-09 | AWS Governance Sprint Day 1 — ADR-001, 4 standards YAMLs, dir rename, ADF fold, global CLAUDE.md, Forge registration, ai-dev cleanup, 7 HARD ref updates. Maturity 5→6/10. |
| 2026-02-24 | CMM maturity model, Why/Realized cascade to 8 components, closed B3/B20/B30 |
| 2026-02-24 | Phase 2 floor raise complete. Phase 3: canonical job registry, capabilities registry accuracy mechanism |

## Next Steps

- [ ] B11/B12 — Trust boundaries + design cascade pattern (foundational governance gaps)
- [ ] B13 — Review Krypton autonomy gates (hook overhead, redaction library necessity)
- [ ] B14 — Review data flow patterns (validate capture and focus synthesis models)
- [ ] B21 — Architecture diagrams (static models still needed)
- [ ] B22 — Documentation standard (per-component doc structure)
