---
standard: agent-freshness-tracking
version: 1.0.0
updated: 2026-05-10
owner: forge
status: active
applies_to: All AWS project artifacts (status.md, BACKLOG.md, lessons.md, design docs, agent definitions) and all repos under ~/code/ that participate in the portfolio scan.
---

# AWS Standard: Agent Freshness Tracking

## Purpose

Eliminate the meta-failure mode where agents read repo files and treat **"present on disk"** as **"currently used."** Every project artifact and agent definition MUST declare its `lifecycle_state` and `last_meaningful_change`, so portfolio scanners (`wm-agent` v0.5+, KB hygiene, wiki regen) and reasoning agents (Krypton, CTO, Forge) can distinguish live patterns from dead references without LLM judgment.

## Why this standard exists

### Incident family (2026-04 through 2026-05)

Repeatedly, agents read repos and surfaced abandoned work as live patterns:

1. **OpenClaw (2026-05-10).** Krypton, CTO, and personal-wiki all cited OpenClaw as current best-practice. OpenClaw had been dead for weeks. The CTO design doc that anchored a Krypton ADR on OpenClaw was itself reading-as-present from a stale inbox doc. 41 files across the portfolio carried live-pattern citations of an abandoned project.
2. **Hermes-the-agent (2026-05-09 + 2026-05-10).** Runtime decommissioned 2026-05-09. The `~/code/_shared/agent-exec/docs/jobs-registry.yaml` registry kept lying about it for a day. Multiple agents reasoned from the stale registry.
3. **Work-management (2026-02-25 → 2026-05-10).** Repo had ~10 weeks of hygiene commits with zero meaningful work. Multiple agents treated WM as a system of record. 480 active tasks in the dead system carried more weight in agent reasoning than the actual portfolio.
4. **`personal-wiki` regen loop (2026-05-10).** Wiki entries auto-regenerated from a stale KB export every 6h. Hand-editing the wiki was wasted effort — the source had to die first.

**Common shape across all four:** absence of an explicit "this is dead now" signal at the artifact level. Agents had no first-class way to ask "is this still live?" — they fell back to file existence.

### Why it can't be fixed by skill-level discipline

Telling every agent "read the date in the frontmatter" doesn't work because:
- Dates exist but mean different things (`updated:` is sometimes hygiene-only, sometimes meaningful change)
- Some artifacts have no dates at all
- Some artifacts are auto-regenerated from upstream sources that themselves are stale (personal-wiki)
- LLMs without an explicit state signal default to "present means active" — it's the path of least token resistance

The fix is to make freshness a **first-class declared field**, not an inferred property.

## The standard

### Required frontmatter fields

Every artifact governed by this standard MUST declare in frontmatter:

```yaml
lifecycle_state: active        # active | stale | abandoned | archived
last_meaningful_change: 2026-05-10   # ISO date — last non-hygiene change
```

### Definitions

| State | Meaning | When to set |
|---|---|---|
| `active` | In current use. Read this and trust it. | Default. Required: `last_meaningful_change` within 90 days OR explicit operational reference (e.g., a launchd job, a current ADR, an open BACKLOG item). |
| `stale` | Was active, hasn't been touched, agents should treat with suspicion. | `last_meaningful_change` > 90d AND no explicit live reference. Set proactively when noticed. |
| `abandoned` | Work started, not finished, not coming back. Read for historical context only. | Explicit decision to stop. Tombstone-banner-in-doc + `lifecycle_state: abandoned`. |
| `archived` | Preserved for trace, definitively dead. Do not reason from. | Moved to `.archive/` OR marked `lifecycle_state: archived`. |

`last_meaningful_change` is NOT auto-updated by hygiene commits, frontmatter freshness stamps, or doctor autofixes. It captures the date of the last commit that changed substance (decision, content, scope) — not the date of the last commit that touched the file.

### Banner convention

When `lifecycle_state: stale | abandoned | archived`, the artifact MUST also carry a top-of-file banner:

```markdown
> **LIFECYCLE: ABANDONED (2026-05-10)**
> Superseded by `docs/active/wm-agent-v0-design.md`.
> Do not use as a source of truth. Kept for historical trace.
```

The banner is what makes the state legible to agents reading the body (in case they skip frontmatter).

### Repo-level declaration

Every repo participating in the portfolio scan MUST declare repo-level lifecycle in its root `status.md` frontmatter:

```yaml
lifecycle_state: active
last_meaningful_change: 2026-05-09
last_substantive_commit: bce6e0f      # Optional — pin to a SHA for the cited change
```

For the repo-level signal, `last_meaningful_change` MUST track the last substantive commit (feat/fix/refactor — not chore/docs hygiene). This is what `wm-agent` v0.5's portfolio scanner consumes.

### Auto-derivable fields (do not hand-edit)

The portfolio scanner derives and writes:

- `freshness_signal` — one of `fresh | warming | stale | dead` based on `last_meaningful_change` age:
  - `fresh`: ≤ 14 days
  - `warming`: 15–30 days
  - `stale`: 31–90 days
  - `dead`: > 90 days, no explicit `lifecycle_state: active` override
- `referenced_by` — list of repos/artifacts that cite this one. Helps detect zombie references.

These live in the scanner's SQLite DB, not in the artifact's frontmatter.

## Required usage patterns

### For agents that read artifacts (Krypton, CTO, Forge, all reasoning agents)

Before citing an artifact as a live pattern:
1. Read its `lifecycle_state`. If not `active`, do NOT cite as live. Cite only as historical context.
2. If frontmatter is missing the field, treat as `unknown` and surface a freshness flag — never assume `active`.
3. If `last_meaningful_change > 90d` AND `lifecycle_state: active`, surface for re-validation. Active-by-declaration plus stale-by-time is a warning sign that the declaration is wrong.

### For agents that write artifacts (Forge, CTO when drafting decisions, Krypton when capturing)

Every new artifact MUST be created with the freshness frontmatter:
- New design docs → `lifecycle_state: active` + `last_meaningful_change: <today>`
- New decision records → `lifecycle_state: active` (ADRs are append-only; the state of the decision can transition without touching the record itself)
- Tombstoning a doc → flip to `abandoned` or `archived` + add banner + bump `updated:` (this counts as a meaningful change to the lifecycle, not to the content)

### For the wm-agent freshness scanner (v0.5+)

Scanner walks `~/code/` and per repo:
1. Reads root `status.md` frontmatter.
2. If missing → flag the repo as `unknown` freshness.
3. If `lifecycle_state: archived` → skip (no further scanning needed).
4. If `lifecycle_state: stale | abandoned` → write a `project_freshness` row but do not scan deeper.
5. If `lifecycle_state: active` → walk `BACKLOG.md`, `lessons.md`, `docs/` for individual artifact freshness signals.
6. Cross-references: if artifact A's `lifecycle_state: active` cites artifact B's `lifecycle_state: abandoned`, write a `stale_reference` row.

The scanner never makes LLM calls. Pure file reads + frontmatter parsing + SQLite writes.

## Compliance

Initial compliance audit filed:

| Artifact | Status | Notes |
|---|---|---|
| `~/code/_shared/krypton/status.md` | non-compliant (no frontmatter freshness fields yet) | Forge to retrofit |
| `~/code/_shared/krypton/docs/active/wm-agent-v0-design.md` | compliant (status: active in frontmatter, has decisions_ref, has supersedes) | OK as reference example for the standard |
| `~/code/_shared/krypton/docs/active/wm-task-ledger-design.md` | compliant by intent (banner-tombstoned 2026-05-10) | Needs `lifecycle_state: abandoned` field added |
| `~/code/_shared/work-management/status.md` | non-compliant | Forge to retrofit with `lifecycle_state: stale` per D3 |
| `~/code/_shared/hermes-deploy/status.md` | partially compliant (has `stage: deprecated` in frontmatter) | Needs canonical `lifecycle_state: archived` field |
| `~/code/_shared/agent-exec/docs/jobs-registry.yaml` | compliant after 2026-05-10 cleanup | hermes-gateway stanza removed |

Full retrofit is a separate Forge workstream (queued as FORGE-P1-X — see `~/.claude/state/forge-backlog.md`). This standard establishes the schema; retrofit happens incrementally as artifacts are touched.

## Migration path

1. **Phase 1 (this standard).** Establish schema and definitions. Forge updates its own state files first as the reference implementation.
2. **Phase 2 (incremental).** Every time an agent touches an artifact, it adds the freshness fields if missing. No "big bang" migration.
3. **Phase 3 (wm-agent v0.5).** Portfolio scanner consumes the fields. Surfaces gaps. Cross-reference checking goes live.
4. **Phase 4 (agent prompts).** Reasoning agents (Krypton, CTO, Forge) get explicit "check `lifecycle_state` before citing" rules in their definitions.

## Shelf life

90 days. Revisit after wm-agent v0.5 ships and we have real data on how often the fields are missing, wrong, or actionable. If the auto-derived `freshness_signal` proves more useful than the declared `lifecycle_state`, simplify by dropping the declared field.

## References

- `~/code/_shared/krypton/docs/active/wm-agent-v0-design.md` § 1 (Freshness is first-class) — the design that elevated this from a nice-to-have to a load-bearing convention.
- `~/code/_shared/krypton/docs/active/stale-ref-audit-2026-05-10.md` — the audit that demonstrated the meta-failure mode in scale.
- `~/code/_shared/krypton/docs/decisions/2026-05-10-wm-redesign-decisions.md` — the decision ledger that authorized this standard.
- `~/code/_shared/aws/docs/standards/mcp-server-env-handling.yaml` — sibling standard with the same shape (incident-driven prevention layer).
