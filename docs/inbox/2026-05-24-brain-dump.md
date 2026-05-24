---
captured: 2026-05-24
by: krypton
status: parked
note: Jesse brain-dump — NOT for immediate action unless flagged below. Captured so it survives.
---

# Brain-dump capture — 2026-05-24

Lightweight board for items Jesse surfaces that don't need thinking-about right now.
Krypton files here on "capture:" with no discussion; we triage later.

## 1. Automation audit + token-burn (resource-usage primitive)

**Trigger:** Weekly usage limit went **80% → 100% overnight** (left ~2026-05-23 afternoon at 80%, returned morning of 2026-05-24 at 100%) **with no manual interaction.** No clarity on where the burn happened.

**Implications:**
- Strongly suggests an autonomous background consumer — cron / launchd job / scheduled agent / a runaway loop — burning tokens unattended.
- If so, it is **recurring every cycle** until found (this is a daily cost leak, not a one-off).
- Points at a missing **AGF primitive: resource-usage / cost observability** — we have no surface that attributes token burn to a source.

**Jesse's stated priority:** not P0, "maybe not even P1 right now." 
**Krypton note:** elevating to *look-right-after-the-foundation-assessment* because it's a recurring cost, not because it's urgent architecture. Read-only investigation (jobs, launchd, logs) only.

## 2. Logging strategy (future — parked)

**Question:** At what point do we start capturing logs, or build a process that scans the core files within each project, summarizes/synthesizes them, and updates them into a logging format?

**Status:** Parked. Not for now. Likely relates to the substrate-layer observability story and the "diary" concept. Revisit when we descend to the substrate/observability layer.

## 3. Merge the two personal-context projects (substrate component)

**Finding:** Two overlapping structured projects exist — `~/personal-context/` and `~/context/`. Both follow the artifact standard. `~/context/` looks like the newer redesign (`_identity`, `_preferences`, `_adapters`, `krypton/`, `agf/`).

**Decision (Jesse, 2026-05-24):** Personal context IS substrate. The two should be **merged and managed as one unit/component.**

**Status:** Captured for later. Krypton will surface the dedupe as part of the portfolio-map exercise; the actual merge is a separate scoped task (likely Forge/CTO).
