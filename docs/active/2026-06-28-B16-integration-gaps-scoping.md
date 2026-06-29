---
title: B16 — Integration Gaps Scoping
author: forge
created: 2026-06-28
status: scoping (for Krypton/AWS-owner triage)
source: AWS BACKLOG B16; Krypton handoff forge/inbox/2026-05-30-aws-integration-gaps-foundation.md
---

# B16 — Integration Gaps: Scope / Effort / Priority

Expands the **6 canonical integration gaps** in `communication-protocols.md §4` into actionable items
with scope, effort, and priority — the B16 ask. Effort uses timeline-recalibration **Layer A**
(build/capability velocity) for build parts; Layer C is flagged where governance maturation binds.

## Key findings (read first)

1. **The "schema-drift subset" the 2026-05-30 handoff worried about does not map to the canonical
   gaps.** The handoff (via the 2026-05-24 aws-framing note) characterized "the 6 gaps" as
   `in-progress` vs `in_progress` / completion-semantics / terminology drift. The **actual** §4 gaps are
   *integration/interface* gaps (missing component-pair wiring), not status-field naming drift. So there
   is effectively **no "clean the schema-drift subset" work inside B16** — B16 is pure scoping. (If a
   real status-vocabulary drift exists, it's a *separate* item, not one of these 6 — flag to confirm.)
2. **4 of the 6 gaps converge on spine operationalization (Krypton-owned, B95) — they are NOT
   independent builds.** Only gaps **#1** and **#3** are truly standalone small items. Gaps **#2, #4,
   #5**, and most of **#6** are facets of "wire the execution/coordination spine." → You can't "invest
   in the 6 gaps" independently of the spine; B16's real output is **2 small standalone items + 4 that
   fold into the spine effort.** This is the load-bearing scoping insight.

## The 6 gaps, scoped

| # | Gap (§4) | Scope (what to build) | Effort (Layer A) | Priority | Spine? |
|---|----------|------------------------|------------------|----------|--------|
| 1 | **KB ↔ Memory no cross-query** | A `related_items` cross-store tool, OR formally accept "Krypton bridges it." | **S** (~½ day for the tool) or 0 (accept status quo) | **P3** | standalone |
| 2 | **Work Mgmt → Krypton no interface** | Expose Krypton as an MCP server (or shared state file) so WM can pull strategic context without a human relay. | **M** (~1–2 days) | **P2** → **P1** when the WM spine goes autonomous | **spine** |
| 3 | **Link Triage → Krypton no routing** | Evolve `/capture` to ingest link-triage output so captures route through Krypton's intelligence (already B3-tagged). | **S–M** (~1 day) | **P2** | standalone |
| 4 | **No event-driven sync (ADF → WM)** | File-watcher / hook-based trigger that propagates ADF artifact changes to WM. | **M** (~1–2 days) | **P2** — gate behind a *live* spine (no point syncing to a dead WM) | **spine** |
| 5 | **No cross-project observability bus** | Unified event stream / shared activity log across components (every-handoff-logged). | **L** (multi-day) | **P1** | **spine** — this IS the ledger + dashboard (B4) + AGF evidence (ADR-005); not a separate build |
| 6 | **Governance layer mostly unbuilt** | Automated drift detection + governance health checks (Krypton Autonomy Governor, B2). | **L** build (Layer A) + **Layer C** maturation | **P1** | partial-spine; Krypton-owned |

## Sequencing recommendation

- **Do now, cheap, standalone:** #1 (decide build-or-accept; likely *accept* — P3) and #3 (the
  `/capture` evolution, ~1 day, already B3-planned). These don't wait on the spine.
- **Fold into the spine build (B95, Krypton-owned), do NOT build standalone:** #2, #4, #5. #5 in
  particular *is* the spine's logged-boundary ledger + dashboard — building it separately would
  duplicate the spine. Per agent-delegation, these are coordinated-with-Krypton, not unilateral Forge.
- **Track under governance (B2), Krypton-owned, already in motion:** #6 — the adaptive-oversight /
  trust-anchor work (ADR D3, cascade C1; trust-boundary model) is already chipping at this.

## Net for B16

B16 can be **closed as "scoped"**: the deliverable (scope/effort/priority per gap) is above. The
*execution* is **not 6 independent investments** — it's 2 small standalone items (#1, #3) plus 4 that
are facets of the spine and should be sequenced inside the spine build, not pulled out. The "integration
alignment" the handoff wanted as a spine prerequisite is therefore largely **automatic**: operationalize
the spine and gaps #2/#4/#5/#6 close as a consequence.
