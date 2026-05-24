---
updated: 2026-05-24
owner: krypton
status: v1-discovery
---

# Portfolio Map — Agentic Work System

This is the v1 cross-project map for the agentic work system itself.
It is the single canonical cross-project view of substrate, operating methodology, agent org, and output components.
North Star: see `../intent.md`.

Scope note: `~/code/clients/**` is tenant/output work and is intentionally excluded from this inventory.
Downloads governance toolkits are also excluded; only `~/Downloads/personal-ai-infra/` is listed as unreconciled brainstorm input.
`~/code/_shared/sources/` is downloaded reference corpus (external framework implementations) — not a system component, excluded.

## Part A — Project Inventory

### Substrate

| Project | Path | What it is (≤8 words) | ADF stage | Owning agent | Freshness (last commit) | Working tree | AGF-alignment |
|---|---|---|---|---|---|---|---|
| Knowledge Base | `/Users/jessepike/code/_shared/knowledge-base` | Optimized knowledge store | "Operate" | unknown | 2026-04-13 | clean | unknown |
| Knowledge Capture | `/Users/jessepike/code/_shared/knowledge-capture` | Capture pipeline into knowledge stores | "Operate" | unknown | 2026-04-11 | clean | unknown |
| Krypton | `/Users/jessepike/code/_shared/krypton` | Chief-of-staff runtime and gateway | "operate" | Krypton | 2026-05-24 | clean | unknown |
| Link Triage Pipeline | `/Users/jessepike/code/_shared/link-triage-pipeline` | Link capture and triage pipeline | "Develop" | unknown | 2026-04-12 | clean | unknown |
| Memory | `/Users/jessepike/code/_shared/memory` | Durable memory layer | "Deliver" | unknown | 2026-04-12 | clean | unknown |
| Nerve Center | `/Users/jessepike/code/_shared/nerve-center` | Observability and findings infrastructure | operate | none; infrastructure consumed by Krypton | 2026-05-24 | clean | unknown |
| Personal Wiki | `/Users/jessepike/code/_shared/personal-wiki` | Generated personal knowledge wiki | operate | unknown | 2026-04-08 | dirty | unknown |
| Pike Dashboard | `/Users/jessepike/code/_shared/pike-dashboard` | Production cockpit for local services | Operate | unknown | 2026-05-24 | clean | unknown |
| Work Management Agent | `/Users/jessepike/code/_shared/wm-agent` | Work dispatcher into Krypton | unknown | Krypton? | 2026-05-10 | clean | unknown |
| Work Management | `/Users/jessepike/code/_shared/work-management` | Todoist-backed work management | "Develop" | unknown | 2026-04-12 | clean | unknown |
| Personal Context | `/Users/jessepike/personal-context` | Durable personal context substrate | Operate | Jesse; agents propose only | 2026-05-15 | dirty | unknown |
| Context Lifecycle Substrate | `/Users/jessepike/context` | Scoped context activation substrate | Operate (dogfood) | unknown | 2026-05-10 | dirty | explicit AGF productization arc |
| Hermes Deploy | `/Users/jessepike/code/_shared/hermes-deploy` | Deprecated Hermes runtime deploy | deprecated | superseded by Krypton | unknown | clean | unknown |

### Operating-Methodology

| Project | Path | What it is (≤8 words) | ADF stage | Owning agent | Freshness (last commit) | Working tree | AGF-alignment |
|---|---|---|---|---|---|---|---|
| AWS | `/Users/jessepike/code/_shared/aws` | Agentic work system governance | operate | Forge | 2026-05-24 | dirty | explicitly AGF-aligned in `docs/intent.md` |
| ADF | `/Users/jessepike/code/_shared/adf` | ADF specs symlink | unknown | Forge? | 2026-05-24 | dirty via AWS | unknown |
| Agentic Work System Alias | `/Users/jessepike/code/_shared/agentic-work-system` | Old AWS symlink alias | unknown | Forge | 2026-05-24 | dirty via AWS | unknown |
| Capabilities Registry | `/Users/jessepike/code/_shared/capabilities-registry` | Skills/plugins/tool registry | "Develop" | Forge; domain agents own entries | 2026-05-23 | clean | unknown |
| Shared Claude Config | `/Users/jessepike/code/_shared/.claude` | Shared Claude context directory | unknown | Forge? | unknown | unknown | unknown |
| Agent Harness | `/Users/jessepike/code/tools/agent-harness` | Tooling harness for agents | unknown | unknown | 2026-04-02 | clean | unknown |
| AI Dev | `/Users/jessepike/code/tools/ai-dev` | Skills and dev-system tooling | operate | Forge | 2026-05-24 | clean | unknown |
| CC Codex Handoff | `/Users/jessepike/code/tools/cc-codex-handoff` | Claude-Code to Codex handoff | unknown | unknown | 2026-04-09 | clean | unknown |

### Agent-Org

| Project | Path | What it is (≤8 words) | ADF stage | Owning agent | Freshness (last commit) | Working tree | AGF-alignment |
|---|---|---|---|---|---|---|---|
| Agent Exec | `/Users/jessepike/code/_shared/agent-exec` | Executive agent workspaces | "develop" | Krypton orchestration layer? | 2026-05-21 | dirty | unknown |
| Pike Agents | `/Users/jessepike/code/_shared/pike-agents` | Agent definitions and personas | "bootstrap" | Krypton orchestrates routing | 2026-05-24 | clean | unknown |

### Output

| Project | Path | What it is (≤8 words) | ADF stage | Owning agent | Freshness (last commit) | Working tree | AGF-alignment |
|---|---|---|---|---|---|---|---|
| Diagram Forge | `/Users/jessepike/code/_shared/diagram-forge` | Shipped diagram MCP product | Develop → approaching OSS launch | Forge + CTO? | 2026-05-06 | dirty | unknown |

## Part B — Active Workstreams

| Workstream | Projects it touches | Current state | Next move |
|---|---|---|---|
| AWS governance refresh | `aws`, `ai-dev`, `capabilities-registry`, `agent-exec`, `memory` | Active but stale-status risk: AWS `docs/status.md` says next entry is governance sprint verification; `docs/intent.md` was refreshed today. | Reconcile status/backlog with current North Star and this portfolio map. |
| Symlink cleanup | `aws`, `_shared/adf`, `_shared/agentic-work-system` | Backlog says both symlinks were temporary safety nets targeted for removal after 3-7 days; they still exist. | Verify downstream references, then route cleanup through Forge. |
| Context substrate reconciliation | `personal-context`, `context` | Both are active substrates; `context/status.md` explicitly defers reconciling `_identity` and `career` with `personal-context`. | Treat as one substrate component until merge/split decision is made. |
| Personal context Phase 1 | `personal-context` | Dirty tree with career, pike-infra, diagrams, and context-design inbox work; status lists Phase 1 through 2026-05-25. | Finish core files, frontmatter retrofit, portability tests, audits, and eval suite. |
| CLS router dogfood | `context`, maybe `personal-context` | v1.2.0 router shipped; status says next is one week dogfood and optional registration in `personal-context`. | Dogfood router, track activation/cache/audit behavior, then decide v1.2.1. |
| Diagram Forge OSS launch | `diagram-forge`, `aws` standards | Dirty data dir; status says OSS prep blocked by exposed-key rotation and plugin distribution fixes. | Rotate keys, fix plugin path hardcoding, fresh-machine smoke test. |
| Agent-org positioning and ownership cleanup | `agent-exec`, `pike-agents`, `personal-context` | Dirty agent-exec tree includes CMO/CTO knowledge and positioning artifacts; AWS backlog also calls for trimming `agent-exec` and future merge into `pike-agents/context`. | Separate current positioning knowledge from structural agent-org cleanup. |
| Knowledge/wiki operationalization (inferred) | `knowledge-base`, `knowledge-capture`, `personal-wiki`, `agent-exec` | Personal wiki status is stale and dirty; agent-exec carries KB Phase 0a handoff notes. | Verify whether KB Phase 0a and wiki sync assumptions are still current. |
| Deprecated Hermes decommission (inferred) | `hermes-deploy`, `krypton` | Hermes is deprecated and superseded by Krypton runtime, but status says the launchd service may still be running as safety net. | After Krypton has handled real wired-channel workload, decommission Hermes. |

## Flags

- `~/personal-context` and `~/context` overlap. Merge candidate: manage as one substrate component until the identity/career reconciliation is resolved.
- Dirty/uncommitted trees: `aws`, `agent-exec`, `diagram-forge`, `personal-wiki`, `personal-context`, and `context`.
- Stale artifacts: `aws/docs/status.md` is 43 days old; `agent-exec/status.md` is 32 days old; `personal-wiki/status.md` is 46 days old.
- `_shared/adf` and `_shared/agentic-work-system` remain symlink aliases after the stated cleanup window.
- `hermes-deploy` is deprecated but may still be running remotely as `ai.hermes.gateway`.
- `diagram-forge` is the only included row classified as Output; most output/tenant work lives under excluded `~/code/clients/**`.

## Brainstorm to reconcile

Unreconciled personal-infra thinking in `/Users/jessepike/Downloads/personal-ai-infra/`:

| File | First heading |
|---|---|
| `design-tokens-tool-technical.md` | Design Tokens — Tool-Technical |
| `diagram-prompt.md` | Diagram Prompt — Personal AI Infrastructure Mental Model |
| `implementation-framework.md` | Implementation Framework — Personal AI Infrastructure |
| `personal-ai-infrastructure.html` | `<!DOCTYPE html>` |
| `session-capture-ingest.md` | Session Capture — Personal AI Infrastructure Substrate Model |

## Gaps surfaced (feeds Design)

- No map-loading mechanism yet: agents can read this file, but nothing makes it a required orientation surface.
- Substrate is fragmented across `personal-context`, `context`, KB, Memory, wiki, and Krypton without one declared boundary model.
- Dirty-tree drift is concentrated in exactly the areas that shape identity, agent org, and launch readiness.
- Symlink aliases show unresolved migration debt from AWS/ADF path consolidation.
- AGF alignment is mostly implicit; only AWS and CLS clearly state it in read files.
- Output classification is underdeveloped because tenant/product work is intentionally excluded from this map.
