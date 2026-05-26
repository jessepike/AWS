---
owner: forge
stage: operate
updated: 2026-05-25
---

# Agentic Work System (AWS)

Meta-project governing the Agentic Work System — the personal baseline for
development workflow, standards, agents, and capabilities across the Pike
Holdings portfolio. It governs how the system's components work together:
integration, governance standards, and component health. It does **not** own any
individual component — it tracks system health, integration gaps, and evolution.

This file (`AGENTS.md`) is the **canonical context source** for all runtimes
(Codex, Gemini, Claude, Cursor, etc.). The root `CLAUDE.md` imports it via
`@AGENTS.md` and layers Claude-specific notes on top (ADR-007 R2).

## Classification

- **Type:** Workflow (governance, integration, operational clarity — not software)
- **Scale:** Personal
- **Scope:** Full system
- **Stage:** Operate & Evolve

## Ownership

- **Primary owner (PM / single point of contact):** Forge.
- **Co-owner / coordinator:** Krypton.
- Split per the Agent Org Charter (§7) and ADR-007: **Forge owns what the system
  *encodes*** — standards YAMLs, ADRs, specs, agent definitions (write authority);
  **Krypton owns the org *map / coordination*** — the charter, portfolio map, and
  cross-agent routing. For AWS governance artifacts the write path is Forge.
- Dev-system write authority is exclusive to Forge per
  `~/.claude/rules/dev-system-ownership.md`; other agents are read-only here and
  route changes through Forge.
- *(The 7-field R5 resolver schema has no co-owner field; co-ownership is recorded
  here in prose. Resolver `owner` = forge.)*

## Orientation sequence (read at session start)

1. This file (`AGENTS.md`) — project context, ownership, constraints.
2. `docs/status.md` — current state, component maturity, session log.
3. `BACKLOG.md` — prioritized improvement items.
4. `docs/intent.md` — North Star; all active work traces back to it (ADR-006).
5. `docs/decisions/` — numbered ADRs (the durable "why"; the decision ledger).
6. `docs/architecture.md` — governing system-level reference (layers, rings, agent teams).
7. `lessons.md` — hot buffer of recent learnings.

## Key locations

| Path | Purpose |
|------|---------|
| `docs/standards/` | Standards YAMLs (project-layout, claude-md, artifact-frontmatter, session-lifecycle) — canonical |
| `docs/decisions/` | Numbered ADRs (decision ledger) |
| `docs/specs/` | Specs (ADF lives at `docs/specs/adf/`) |
| `docs/active/` | Working documents (portfolio-map, charter, pilots) |
| `docs/intent.md` | North Star: problem, outcome, success criteria |
| `docs/architecture.md` | Governing system-level reference |
| `docs/status.md` | Current state, component maturity, session log |
| `docs/brief.md` | Scope, success criteria, component inventory |
| `docs/component-registry.md` | Component registry |
| `docs/overview.md` | Canonical AWS-vs-AGF-vs-ADF system overview (read first if unfamiliar) |
| `~/code/_shared/nerve-center/config/jobs.yaml` | Canonical list of running monitoring jobs |

## Component projects

| Component | Location |
|-----------|----------|
| ADF | `docs/specs/adf/` |
| Knowledge Base | `~/code/_shared/knowledge-base/` |
| Memory | `~/code/_shared/memory/` |
| Capabilities Registry | `~/code/_shared/capabilities-registry/` |
| Krypton | `~/code/_shared/krypton/` |
| Link Triage | `~/code/_shared/link-triage-pipeline/` |
| Work Management | `~/code/_shared/work-management/` |
| Nerve Center | `~/code/_shared/nerve-center/` |

## Constraints

- **Standards YAMLs are canonical** — do not modify without explicit approval and
  an ADR entry in `docs/decisions/`.
- This is a governance/workflow project: it produces docs, standards, and
  coordination artifacts — **not software**.
- All Forge-owned projects must conform to the standards defined here.
- `docs/architecture.md` is the governing reference — changes require review.
- Backlog items should be traceable to the architecture (which gap does this close?).
- Never modify `.claude/rules/` or `docs/intent.md` without explicit human approval.
- Never commit secrets, credentials, or API keys; confirm before destructive
  operations; ask when uncertain rather than assume.

## Workflow norms

- Changes to standards flow through the ADR process in `docs/decisions/`.
- Backlog items are often built inside component projects — audit against
  component backlogs/status before assuming an item is still open.
- Cross-project learnings → Memory MCP; project-local conventions stay in this file.

## Session protocol

1. **Start:** Read `docs/status.md` — understand current state, last session, next steps.
2. **Work:** Reference `docs/architecture.md` and `BACKLOG.md` for context.
3. **End:** Update `docs/status.md` — log what was done, update next steps.

## Contract conformance (ADR-007 per-project contract)

Adopted via the per-project contract pilot (Pilot #3 — the reflexivity test: the
governance project applying its own standard). Two non-obvious interpretation
calls are recorded here so they are discoverable:

- **R3 (decision ledger):** `docs/decisions/` (numbered ADRs) satisfies R3 — it is
  the listed `alt_paths` entry for `decisions.md` in `project-layout.yaml`. No root
  `decisions.md` pointer is added; it would be a near-empty duplicate.
- **Dual `CLAUDE.md`:** aws has both a root `CLAUDE.md` and a `.claude/CLAUDE.md`,
  and Claude Code loads **both**. To avoid double-importing canonical context, the
  **root `CLAUDE.md` is the importer** (`@AGENTS.md` + Claude overlay); the
  `.claude/CLAUDE.md` is a thin pointer that does **not** re-import. Both carry
  `owner: forge` frontmatter.
