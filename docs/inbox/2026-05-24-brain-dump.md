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

**Findings (2026-05-24, read-only agent sweep):**
- Not one leak. ~25 scheduled `claude -p` jobs across macbook2014 + laptop burn ~100+ calls/day, with no surface showing it.
- **NC scheduler dominates:** ~80 calls/day, 24/7 (hourly Sonnet `governance-sentinel` + 30-min Haiku `health-prober`); 3,661 calls over ~46 days. Expected behavior, but the bulk of overnight burn.
- **80→100% overnight = cumulative** (NC overnight + Sunday-morning convergence of kc + il jobs), not a single runaway event.
- **Hermes ruled out** — confirmed dead; registry cleaned 2026-05-10.
- **One wasteful soft-loop:** `il-classifier-sweep` re-processes 7 stuck entries in `krypton/docs/lessons.md` every 4h forever (text-match bug, never self-heals) — ~12 wasted Haiku calls/day.
- `claude-md-audit` + `weekly-digest` already auto-disabled 2026-05-24 (were failing).

**Recommended fixes (all dev-system → route to Forge):**
1. Clear/mark the 7 stuck il-classifier entries + fix the text-match so it self-heals. (P1, cheap, stops daily waste.)
2. NC rate tradeoff — observability vs cost (`governance-sentinel` hourly→2h, `infra-monitor`→2h ≈ halves NC). **Jesse judgment call.**
3. kc synthesis Sonnet→Haiku or batch the three. (P3)

**Meta:** This IS the resource-usage / cost-observability AGF primitive gap, made concrete — no standing surface attributes token burn. Candidate: a pike-dashboard token-burn panel.

## 2. Logging strategy (future — parked)

**Question:** At what point do we start capturing logs, or build a process that scans the core files within each project, summarizes/synthesizes them, and updates them into a logging format?

**Status:** Parked. Not for now. Likely relates to the substrate-layer observability story and the "diary" concept. Revisit when we descend to the substrate/observability layer.

## 3. Merge the two personal-context projects (substrate component)

**Finding:** Two overlapping structured projects exist — `~/personal-context/` and `~/context/`. Both follow the artifact standard. `~/context/` looks like the newer redesign (`_identity`, `_preferences`, `_adapters`, `krypton/`, `agf/`).

**Decision (Jesse, 2026-05-24):** Personal context IS substrate. The two should be **merged and managed as one unit/component.**

**Status:** Captured for later. Krypton will surface the dedupe as part of the portfolio-map exercise; the actual merge is a separate scoped task (likely Forge/CTO).

## 4. Scratch / execution-durability items (2026-05-24, from workstream brief)

- **[FOUNDATION primitive] Per-project contract + assigned PM/owner.** Recurring theme across the whole workstream brief: every project needs a single **lead/PM** (one point of contact who directs the work and holds its state) AND a standard **core-artifact set** — a repo-root CLAUDE.md that names the PM/owner, plus project map, resolver, intent, architecture — so any agent orienting to a project ingests a known set and minimizes assumptions/stale info. This is Jesse priority #1 foundation and resolves the "who owns this?" question recurring in nearly every workstream. → **Design next.**
- **Directory-maintenance skill + weekly schedule.** Reuse existing ADF-audit tooling. Assign owner + schedule + wire it up so it actually fires. Execution/durability, not design. → Forge (skill + launchd schedule).
- **Agent-canvas app** — agents write HTML surfaces for interaction. `sandbox/agent-canvas` exists. → explore later.

## Jesse priority stack (2026-05-24) — Krypton's operating order
1. Build AWS / personal operating infrastructure foundation + how Jesse↔Krypton work, prioritize, execute, track.
2. Clean up stale/bad jobs; token conservation + optimization.
3. CLS + personal-context.
4. Work/task-management capability (the spine).
5. Change workflow to adopt new processes.
6. Marcus coach (new interaction approach).
7. Krypton personal-agent capabilities.
8. Core substrate health (KB, memory): current state, future state, gaps.

## 5. Forge parallel-session handoff (2026-05-25)

**Rules durability gap (Forge-flagged → Forge backlog):** `~/.claude/rules/` (agent-delegation.md, bias-to-action.md) — same class: Krypton inbox notes + agent state files — *take effect* durably (load every turn / surface on orient) but are NOT git-tracked or backed up. If this Mac dies, they're gone. Reconstructable from ADR-004 (committed), but the files themselves are single-machine/unversioned. Fix: back `~/.claude/rules/` (+ inbox/state) into a tracked location. **This is the SAME "takes effect by existing but not preserved" durability gap as our cross-session-visibility thread — treat as one durability primitive.** → Forge (config-management decision).

**Parallel-work shipped (Forge session, pre-dating this Krypton session):** ADR-004 + ADR-005 → aws `b3f8f48`; agent CHANGELOG → pike-agents `ee5bd2e`; the two rules → `~/.claude/rules/` (untracked, see gap). Two notes now in Krypton inbox: the decisions/review-set + a **token-accounting requirement** — pending Krypton processing on next orient.

## 6. Forge headless session completion (2026-05-25)

**De-drift sweep completed:**
- aws/VERSION: 1.0.0 → 1.3.0 (committed `d51d844`)
- aws/docs/overview.md: dead work-management spine claim corrected; absorbed Tools agent removed from count (9→8); AGF doctrine sentence held for ADR-005 (committed `d587890`)
- Symlinks `_shared/adf` and `_shared/agentic-work-system`: **NOT removed** — both have live active references (pike-acm `.mcp.json` → `_shared/adf`; `cto/CLAUDE.md`, work-management, link-triage-pipeline → `_shared/agentic-work-system`). Removal requires coordinated ref updates first; deferred.
- Global `.DS_Store` gitignore: already configured at `~/.gitignore_global` (via `core.excludesfile`) — verified, no change needed.

**NC token-burn P0:**
- NC-51 logged in nerve-center `BACKLOG.md`, marked DONE (committed `52a188a`)
- il-classifier match bug fixed in `aws/scripts/il-classifier.sh` — Haiku strips markdown (`**`, backtick) from `.entry`, so `index($5, entry)` never matched the full-markdown candidate; now normalizes both sides before the substring test (committed `5fdefe9`)
- 7→8 stuck `[pending]` entries cleared from `krypton/lessons.md` — markers stripped so they revert to `new` candidates; fixed classifier routes them to KB on next 4h sweep (committed `9a88754`)
- forge inbox 2026-05-24 batch marked `done` + agent-exec CLAUDE.md de-drift (committed `32ecbf3`)

**Commit hashes:**
- aws: `d51d844`, `d587890`, `5fdefe9` (+ this brain-dump update)
- nerve-center: `52a188a`
- krypton: `9a88754`
- agent-exec: `32ecbf3`

**Not pushed** — all commits local per session constraint. AGF doctrine sentence untouched. NC job rates (governance-sentinel / infra-monitor) untouched.
