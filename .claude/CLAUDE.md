# Agentic Work System — Project Context

## Classification

- **Type:** Workflow (governance, integration, operational clarity — not software)
- **Scale:** Personal
- **Scope:** Full system
- **Stage:** Operate & Evolve

## What This Project Is

The meta-project governing how the agentic work system's components work together. It tracks system health, integration gaps, and evolution — but does not own any individual component.

## Key Artifacts

- `docs/architecture.md` — System-level architecture (layers, rings, boundaries, agent teams)
- `docs/intent.md` — North star: problem, outcome, success criteria
- `docs/status.md` — Current state, component maturity, session log
- `docs/brief.md` — Scope, success criteria, component inventory
- `BACKLOG.md` — Prioritized improvement items seeded from brainstorm
- `~/code/_shared/nerve-center/config/jobs.yaml` — canonical list of running monitoring jobs

## Component Projects

| Component | Location |
|-----------|----------|
| ADF | `~/code/_shared/adf/` |
| Knowledge Base | `~/code/_shared/knowledge-base/` |
| Memory | `~/code/_shared/memory/` |
| Capabilities Registry | `~/code/_shared/capabilities-registry/` |
| Krypton | `~/code/_shared/krypton/` |
| Link Triage | `~/code/_shared/link-triage-pipeline/` |
| Work Management | `~/code/_shared/work-management/` |
| Nerve Center    | `~/code/_shared/nerve-center/` |

## Working Norms

- This project produces governance, not code
- Changes to architecture.md require careful consideration — it's the governing reference
- Backlog items should be traceable to the architecture (which gap does this close?)
- Status.md is updated every session per the Agent Session Protocol
- Cross-project learnings go to Memory MCP; project-local conventions stay here
- Backlog items are often built inside component projects — audit against component backlogs/status before assuming items are still open

## Session Protocol

1. **Start:** Read `docs/status.md`. Understand current state, last session, next steps.
2. **Work:** Reference `docs/architecture.md` and `BACKLOG.md` for context.
3. **End:** Update `docs/status.md` — log what was done, update next steps.
