# Status: Agentic Work System

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
| 2026-04-09 | AWS Governance Sprint Day 1 — ADR-001, 4 standards YAMLs, dir rename, ADF fold, global CLAUDE.md, Forge registration, ai-dev cleanup, 7 HARD ref updates. Maturity 5→6/10. |
| 2026-02-24 | CMM maturity model, Why/Realized cascade to 8 components, closed B3/B20/B30 |
| 2026-02-24 | Phase 2 floor raise complete. Phase 3: canonical job registry, capabilities registry accuracy mechanism |

## Next Steps

- [ ] B11/B12 — Trust boundaries + design cascade pattern (foundational governance gaps)
- [ ] B13 — Review Krypton autonomy gates (hook overhead, redaction library necessity)
- [ ] B14 — Review data flow patterns (validate capture and focus synthesis models)
- [ ] B21 — Architecture diagrams (static models still needed)
- [ ] B22 — Documentation standard (per-component doc structure)
