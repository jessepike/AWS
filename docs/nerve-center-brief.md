---
type: "component-brief"
component: "Nerve Center"
description: "Canonical governance/intent brief for Nerve Center — the Observability Ring runtime for the Agentic Work System. This is the single authoritative doc on what NC is, why it exists, and how it fits AWS."
version: "1.0.0"
created: "2026-02-11"
updated: "2026-04-13"
scope: "system"
lifecycle: "canonical"
owner: "Jess"
status: "active"
supersedes: ["prior concept brief at aws/docs/nerve-center-brief.md v0.1.0"]
related:
  - "~/code/_shared/nerve-center/docs/ (design + operational state)"
  - "~/code/_shared/agent-exec/docs/jobs-registry.yaml (live job inventory)"
  - "~/code/_shared/aws/docs/architecture.md (governing architecture)"
  - "~/code/_shared/aws/docs/decisions/ADR-002-canonical-doc-homes.md (doc-home rule)"
backlog-refs: ["B4", "B21", "B9"]
---

# Nerve Center — AWS Governance Brief

> **Canonical home:** this file. If you want to know what Nerve Center is,
> why it exists, or how it fits the Agentic Work System, read this. For
> code, runbooks, and operational detail see
> `~/code/_shared/nerve-center/docs/`. For the live job inventory across
> hosts see `~/code/_shared/agent-exec/docs/jobs-registry.yaml`.

## What Nerve Center is

Nerve Center (NC) is the **runtime implementation of the Observability
Ring** from the AWS architecture. It watches the rest of the system —
MCP servers, launchd jobs, project status artifacts, capability registry
health, knowledge pipelines — and produces structured findings plus
operator-facing alerts. It is the mechanism that makes the principle
*"you can't increase autonomy for what you can't observe"* operational.

NC is one of the `_shared/` runtime components. It is a **peer** of the
other AWS runtime components (Knowledge Base, Memory, Capabilities
Registry, Krypton, Work Management, Link Triage) — it is not part of
AWS itself. AWS governs NC via standards and ADRs; NC reports back into
AWS via observability signal.

## Why it exists

The AWS architecture defines four layers (Intent → Governance →
Management → Operations) and five rings (Governance, Intelligence,
Knowledge, Control, Observability). The Observability Ring is the
prerequisite for autonomy escalation at every layer — trust is built on
evidence, and evidence requires monitoring that is continuous, structured,
and correlatable across subsystems.

Before NC, observability across the portfolio meant:

- Reading 7+ `status.md` files manually
- Running `/krypton:kstatus` for a text snapshot
- Running `/adf-env:audit` per project
- Checking git logs for activity
- Reviewing audit logs under `~/.krypton/audit/`

That is operationally expensive, fragmented, and lossy. It does not produce
structured findings that other agents can act on, and it cannot alert when
something degrades between sessions. NC exists to close that gap with a
runtime that watches continuously, writes findings to a durable store,
and pages the operator when a RED threshold trips.

## Responsibilities

NC owns, end to end:

| Responsibility | Detail |
|---|---|
| **Infrastructure probes** | Scheduled shell probes check MCP servers (ports 9101/9102), NC API, scheduler heartbeat, launchd jobs, disk/backup state |
| **Finding generation** | Probes emit structured findings (severity + category + evidence) into SQLite with WAL |
| **Finding dedup + lifecycle** | Duplicate findings suppressed; resolved findings auto-close; stale findings escalate |
| **Operator alerting** | RED findings push to `#nerve-center-critical` via Slack webhook; WARN aggregated into daily digest |
| **Dead-man's switch** | `com.claude.nc-heartbeat` launchd job fires every 4h; absence means NC itself is down |
| **Operator workflow UI** | `@nerve-center/desktop` provides incident view, acknowledge/resolve actions, trace of signal streams |
| **Health surface** | `/api/health` (open) and `/api/ops/runtime` (auth) for external health checks and for Krypton/forge diagnostics |

NC does **not** own:

- Strategic prioritization (Krypton)
- Work state (Work Management)
- Knowledge or memory (KB / Memory)
- Capability catalog (Capabilities Registry)
- Project governance checks (ADF + `/project-doctor` skill)

Those systems push signal *into* NC as findings where relevant. NC
observes; it does not decide.

## Fit in AWS rings and layers

NC primarily instantiates the **Observability Ring** and feeds the
**Governance Ring** (via alignment/drift findings that reach Krypton).

| Ring | NC's role |
|---|---|
| Observability | Primary — probes, findings store, alerting, UI |
| Governance | Secondary — drift and stale-work findings inform governance health |
| Knowledge | Consumer — reads KB/Memory process state for health |
| Control | Consumer — permissioned API access for operator |
| Intelligence | Not NC — synthesis of findings happens in Krypton |

| Layer | NC's role |
|---|---|
| Intent | None |
| Governance | Provides evidence; does not govern |
| Management | None |
| Operations | Primary consumer — most findings describe operations-layer state |

## Runtime baseline

NC is **not** deployed to any cloud provider. It runs as local launchd
jobs on `macbook2014`. Previous Railway deployment was abandoned in
early 2026; the archived Railway-era docs live at
`~/code/_shared/nerve-center/docs/adf/_archived/railway-era/`. NC will
not be re-hosted on Railway. If cloud hosting is ever reconsidered, it
starts from a new brief.

Live deployment facts — **see `agent-exec/docs/jobs-registry.yaml`** for
the authoritative inventory. Do not duplicate that inventory here.

The minimum facts stable enough to live in governance:

- Scheduler: `com.nerve-center.scheduler` launchd job on macbook2014
- API: `http://localhost:9100` on macbook2014 LAN
- Persistence: SQLite (WAL) on macbook2014 local volume
- Backup: 24 hourly + 7 daily snapshots, local destination
- Dead-man's switch: `com.claude.nc-heartbeat`, 4h cadence
- Alerts: Slack `#nerve-center-*`

Anything that changes when NC is redeployed, retuned, or rebalanced —
ports, hosts, service names, env vars — belongs in the NC project's own
docs and the jobs registry, not here.

## Design principles

These are the governance-level commitments. NC's internal design docs
may elaborate; they may not contradict.

1. **Read-only for humans, structured writes for agents.** NC observes
   agent-native state. It does not introduce new data flows.
2. **Findings are durable and structured.** Every observation goes to
   SQLite with severity, category, source probe, and evidence payload.
3. **Signals, not data.** The UI surfaces what needs attention. Raw
   data stays in the store.
4. **Local-first, personal-scale.** No cloud dependency. No multi-user
   surface. Local launchd is the scheduler.
5. **Agent-first parity.** Everything the UI shows is queryable by
   agents via the NC API, so Krypton and Forge can read the same state.
6. **Dead-man's switch is non-negotiable.** NC watching the system
   requires a separate mechanism watching NC.

## When to talk to Forge about NC

| Topic | Owner |
|---|---|
| What NC *is* for, what rings it serves, governance posture | Forge (update this file) |
| New probe type, new finding category, schema changes | NC project owner (design doc + ADR if cross-cutting) |
| Deployment or hosting change | NC project owner + ADR (because it moves governance facts) |
| Adding NC-related job to launchd | NC project owner + registry update in agent-exec |
| Drift between this brief and NC reality | Forge (reconcile) |

## References

- NC project docs: `~/code/_shared/nerve-center/docs/`
- NC manifest (runtime): `~/code/_shared/nerve-center/docs/adf/manifest.md`
- NC status: `~/code/_shared/nerve-center/status.md`
- NC changelog: `~/code/_shared/nerve-center/CHANGELOG.md`
- Archived Railway-era docs: `~/code/_shared/nerve-center/docs/adf/_archived/railway-era/`
- Live job inventory: `~/code/_shared/agent-exec/docs/jobs-registry.yaml`
- Governing architecture: `~/code/_shared/aws/docs/architecture.md`
- Canonical-doc-home rule: `~/code/_shared/aws/docs/decisions/ADR-002-canonical-doc-homes.md`

## Revision history

| Version | Date | Change |
|---|---|---|
| 0.1.0 | 2026-02-11 | Original concept brief for NC as visual interface — broader scope (UI vision, MVP phases, technical stack). Superseded. |
| 1.0.0 | 2026-04-13 | Rewritten as canonical governance brief. Scope tightened to what-it-is / why / responsibilities / fit in AWS. Product design and stack detail moved to NC project docs. Railway deployment language removed. |
