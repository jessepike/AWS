---
type: "portfolio-map"
title: "Portfolio Map — Agentic Work System Canonical Draft"
scope: "Pike Holdings agentic portfolio"
updated: "2026-05-25"
owner: "krypton"
status: "draft-for-krypton-review"
review-needed: "Krypton review on 2026-05-25"
supersedes:
  - "/Users/jessepike/code/clients/risk/agf-applied/portfolio-map.md (2026-05-22 source; do not delete)"
  - "/Users/jessepike/code/_shared/aws/docs/active/portfolio-map.md (2026-05-24 filesystem sweep)"
canonical-companions:
  - "/Users/jessepike/code/_shared/aws/docs/active/workstream-brief.md"
  - "/Users/jessepike/code/_shared/agent-exec/docs/pike-infrastructure.md"
  - "/Users/jessepike/code/clients/risk/agf-applied/README.md"
  - "/Users/jessepike/code/clients/risk/AGF/docs/agentic-primitives.md"
---

# Portfolio Map — Agentic Work System Canonical Draft

This is the reconciled canonical draft for the agentic portfolio map. It merges:

- the richer AGF-layer classification from `/Users/jessepike/code/clients/risk/agf-applied/portfolio-map.md`;
- the fresher four-layer filesystem inventory from the previous active AWS map;
- Jesse's hand-confirmed workstream truth in `workstream-brief.md`.

Jesse's workstream brief wins for owners, active/in-flight status, workstream reality, and priority stack. Filesystem state from the 2026-05-24 sweep wins for freshness, working-tree state, and project rows. The 2026-05-22 `agf-applied` map remains valuable source material but is superseded by this active map for portfolio operating use.

## Reconciliation notes — Krypton review needed

### What was merged

- Preserved the `agf-applied` map's AGF layer classifications: Observability, Security, Governance, Decision Intelligence, Agent Harnesses, plus cross-cutting substrate/channel notes.
- Preserved the active AWS map's four-layer operating inventory: Substrate, Operating-Methodology, Agent-Org, Output.
- Overlaid the active AWS map's fresher filesystem state: ADF stage, last commit freshness, working-tree status, and inferred owner where available.
- Replaced inferred Part B workstreams with Jesse-confirmed workstreams from `workstream-brief.md`.
- Carried Jesse's priority stack into the map as the working portfolio priority order.
- Marked the `agf-applied` original as superseded-by-this in frontmatter without deleting or modifying it.

### Conflicts found

- **Scope conflict:** the `agf-applied` map includes AGF itself, downstream products, and client/output consumers as classification context; the active AWS map intentionally excludes `~/code/clients/**` tenant/output work. This draft keeps AGF classification context but keeps the operating inventory focused on the four-layer AWS portfolio.
- **Owner conflict:** the active AWS map inferred AWS as Forge-owned; Jesse clarified AWS governance refresh is **Krypton + Forge**.
- **Work-management conflict:** the `agf-applied` map says `wm-agent` is paused/unloaded; Jesse clarified the broader **WM / task-management revision** is active and priority work owned across CTO, Forge, Krypton, and Jesse.
- **Knowledge/wiki conflict:** the `agf-applied` map classifies Personal Wiki as operating; Jesse clarified the wiki may be live but is **not operationally used** and should fall under the KB project/owner, puntable to P1/P2.
- **Diagram Forge priority conflict:** inferred map treated OSS launch as an active workstream; Jesse clarified it can be **P1**, not a core need right now.
- **Symlink cleanup timing conflict:** inferred next move was immediate verification/removal; Jesse clarified Forge should do it, but after 11pm Sunday 2026-05-24 when weekly token allotment resets.
- **PM model conflict:** inferred owners are inconsistent across projects; Jesse clarified each project needs a single PM-style lead, and several projects do not yet have one.

### Unresolved / uncertain

- Several substrate projects still lack a confirmed PM/owner: Knowledge Base, Knowledge Capture, Link Triage Pipeline, Memory, Personal Wiki, Work Management, Personal Context, Context Lifecycle Substrate.
- Context substrate reconciliation lacks a final owner. Jesse suggested the owner might be declared in a repo-root artifact such as `CLAUDE.md`, but this is not settled.
- Personal Context Phase 1 is real but not yet implemented; owner/PM is not settled beyond Jesse/agent-proposed governance.
- CLS router dogfood is new and not implemented; owner/PM is unknown.
- KB/wiki operationalization should likely sit under the KB project owner, but that owner is unknown.
- Agent Canvas app appears in Jesse's missed list but has no visible filesystem row in this inventory yet.
- AGF catalog-layer decisions remain open for boundary surfaces and substrate/environment governance.
- This is a draft for Krypton review; do not treat unresolved owner assignments as authoritative.

## How to read this map

- **Part A** is the four-layer project inventory: Substrate, Operating-Methodology, Agent-Org, Output.
- **AGF layer/classification** keeps the richer `agf-applied` interpretation where available.
- **ADF stage / freshness / working tree / owner** come from the 2026-05-24 filesystem sweep unless Jesse overrode them.
- **Part B** is the real workstream layer confirmed by Jesse. It is the operating layer for what is active, in flight, and next.
- **Priority stack** is Jesse's current focus order, not a derived backlog ranking.

## Part A — Four-layer project inventory

### Layer 1: Substrate

Substrate is the knowledge, memory, context, capture, observability, and operating-state foundation. AGF mapping is mostly Primitive #19 Agent Environment Governance, with Memory also touching P#12 Memory-Augmented Reasoning and Nerve Center/Pike Dashboard touching Observability.

| Project | Path | What it is | ADF stage | PM / owning agent | Freshness | Working tree | AGF layer / classification | Current state |
|---|---|---|---|---|---|---|---|---|
| Knowledge Base | `/Users/jessepike/code/_shared/knowledge-base` | Optimized knowledge store | Operate | unknown; likely needed under KB owner | 2026-04-13 | clean | Substrate / P#19 | Operating substrate; ownership unclear. |
| Knowledge Capture | `/Users/jessepike/code/_shared/knowledge-capture` | Capture pipeline into knowledge stores | Operate | unknown; likely KB-adjacent | 2026-04-11 | clean | Substrate / P#19 | Operating capture path; owner unclear. |
| Krypton | `/Users/jessepike/code/_shared/krypton` | Chief-of-staff runtime and gateway | Operate | Krypton | 2026-05-24 | clean | Agent Harness + Security + Governance | Operating runtime/gateway; personal-agent capabilities are priority #7. |
| Link Triage Pipeline | `/Users/jessepike/code/_shared/link-triage-pipeline` | Link capture and triage pipeline | Develop | unknown | 2026-04-12 | clean | Substrate / P#19-adjacent | Operating or near-operating capture feeder; owner unclear. |
| Memory | `/Users/jessepike/code/_shared/memory` | Durable memory layer | Deliver | unknown | 2026-04-12 | clean | Decision Intelligence substrate / P#12 + P#19 | Operating substrate; DI synthesis is not built. |
| Nerve Center | `/Users/jessepike/code/_shared/nerve-center` | Observability and findings infrastructure | Operate | no PM; infrastructure consumed by Krypton | 2026-05-24 | clean | Observability | Operating; most mature AGF-applied layer. |
| Personal Wiki | `/Users/jessepike/code/_shared/personal-wiki` | Generated personal knowledge wiki | Operate | unknown; should fall under KB owner | 2026-04-08 | dirty | Substrate / P#19 | May be live but not operationally used; puntable P1/P2. |
| Pike Dashboard | `/Users/jessepike/code/_shared/pike-dashboard` | Production cockpit for local services | Operate | unknown | 2026-05-24 | clean | Observability / operator cockpit | Operating; local service cockpit. |
| Work Management Agent | `/Users/jessepike/code/_shared/wm-agent` | Work dispatcher into Krypton | unknown | Krypton?; PM model unresolved | 2026-05-10 | clean | Agent Harness / work spine | `wm-agent` itself was previously paused; broader WM/task spine is active priority work. |
| Work Management | `/Users/jessepike/code/_shared/work-management` | Todoist-backed work management | Develop | CTO + Forge + Krypton + Jesse pieces; no single PM yet | 2026-04-12 | clean | Governance + work/task spine | Active priority project; defines capture, routing, visibility, auditability, and dashboard spine. |
| Personal Context | `/Users/jessepike/personal-context` | Durable personal context substrate | Operate | Jesse; agents propose only; PM not assigned | 2026-05-15 | dirty | Substrate / P#19 | Active, with Phase 1 threads not yet pulled together. |
| Context Lifecycle Substrate | `/Users/jessepike/context` | Scoped context activation substrate | Operate / dogfood | unknown | 2026-05-10 | dirty | Explicit AGF productization arc / P#19 | Active but new; CLS router dogfood not yet implemented. |
| Hermes Deploy | `/Users/jessepike/code/_shared/hermes-deploy` | Deprecated Hermes runtime deploy | deprecated | superseded by Krypton | unknown | clean | Legacy boundary/runtime | Deprecated; decommission after Krypton proves wired-channel workload. |

### Layer 2: Operating-Methodology

Operating-Methodology holds AWS/ADF, standards, capability registry, project governance, and development-system tooling. AGF mapping is primarily Governance and Environment Governance.

| Project | Path | What it is | ADF stage | PM / owning agent | Freshness | Working tree | AGF layer / classification | Current state |
|---|---|---|---|---|---|---|---|---|
| AWS | `/Users/jessepike/code/_shared/aws` | Agentic work system governance | Operate | Krypton + Forge | 2026-05-24 | dirty | Governance / P6 | Active canonical operating map; governance refresh in flight. |
| ADF | `/Users/jessepike/code/_shared/adf` | ADF specs symlink | unknown | Forge? | 2026-05-24 | dirty via AWS | Governance / P6 | Symlink alias; cleanup pending through Forge. |
| Agentic Work System Alias | `/Users/jessepike/code/_shared/agentic-work-system` | Old AWS symlink alias | unknown | Forge | 2026-05-24 | dirty via AWS | Governance / migration artifact | Temporary alias; cleanup pending after token reset window. |
| Capabilities Registry | `/Users/jessepike/code/_shared/capabilities-registry` | Skills/plugins/tool registry | Develop | Forge; domain agents own entries | 2026-05-23 | clean | Substrate / P#19 capabilities layer | Operating registry; one of the core substrate components to keep healthy. |
| Shared Claude Config | `/Users/jessepike/code/_shared/.claude` | Shared Claude context directory | unknown | Forge? | unknown | unknown | Governance / configuration | Owner likely Forge; exact state unknown. |
| Agent Harness | `/Users/jessepike/code/tools/agent-harness` | Tooling harness for agents | unknown | unknown | 2026-04-02 | clean | Agent Harness | AGF-applied harness catalog entry is in-flight/public alpha. |
| AI Dev | `/Users/jessepike/code/tools/ai-dev` | Skills and dev-system tooling | Operate | Forge | 2026-05-24 | clean | Governance + tooling | Operating dev-system tooling; Forge-owned. |
| CC Codex Handoff | `/Users/jessepike/code/tools/cc-codex-handoff` | Claude-Code to Codex handoff | unknown | unknown | 2026-04-09 | clean | Tooling / workflow bridge | Operating status unknown. |

### Layer 3: Agent-Org

Agent-Org is the role/harness layer: agents, teams, hierarchy, routing, invocation, and authority boundaries. AGF mapping is Agent Harnesses, Governance, and Trust Ladder territory.

| Project | Path | What it is | ADF stage | PM / owning agent | Freshness | Working tree | AGF layer / classification | Current state |
|---|---|---|---|---|---|---|---|---|
| Agent Exec | `/Users/jessepike/code/_shared/agent-exec` | Executive agent workspaces | Develop | Krypton orchestration layer?; PM unresolved | 2026-05-21 | dirty | Agent Harness + subscription routing | Active cleanup/positioning work; future merge into `pike-agents/context` remains open. |
| Pike Agents | `/Users/jessepike/code/_shared/pike-agents` | Agent definitions and personas | Bootstrap | Krypton orchestrates routing; Forge involved in structure | 2026-05-24 | clean | Agent Harnesses + Governance | Active open session per Jesse; defines agent teams, roles, hierarchy, harnesses, invocation model. |

### Layer 4: Output

Output projects consume the AGF-governed stack. The `agf-applied` map classifies downstream products as consumers rather than AGF layer instances; this operating inventory keeps only the visible shared output row from the filesystem sweep.

| Project | Path | What it is | ADF stage | PM / owning agent | Freshness | Working tree | AGF layer / classification | Current state |
|---|---|---|---|---|---|---|---|---|
| Diagram Forge | `/Users/jessepike/code/_shared/diagram-forge` | Shipped diagram MCP product | Develop -> approaching OSS launch | Forge + CTO? | 2026-05-06 | dirty | Output consumer; cross-cutting tooling | Real workstream but not core right now; P1 launch cleanup. |

### AGF layer summary

| AGF layer | Portfolio state | Highest-confidence components | Gap / review note |
|---|---|---|---|
| Observability | Most mature layer | Nerve Center, Pike Dashboard, findings.db, audit JSONLs | nc-heartbeat unloaded, semantic-quality unbuilt, audit aggregation incomplete. |
| Security | Operating but uncatalogued | agent-bridge, ChatMock, Krypton gateway, Slack/Telegram allowlists | Security catalog entry is still a stub; gateway-enforced Bounded Agency is a likely first entry. |
| Governance | Deeply present but uncatalogued | AGF, ADF, AWS, Capabilities Registry, Krypton gates, Forge write partitioning | GDR emission at gate boundaries is unbuilt; trust ladder declarations are uncodified. |
| Decision Intelligence | Corpus exists; synthesis unbuilt | Memory, audit JSONLs, findings.db, decisions.md, lessons.md | RDG / Claims / Beliefs / Revision Cascade / Decision Memo are not implemented. |
| Agent Harnesses | Operating but unevenly catalogued | agent-harness, Krypton runtime, pike-agents, agent-exec, wm-agent | Tier 2 orchestration harness is missing; pike-agent trust tiers uncodified. |
| Substrate / Environment | Real but not a formal AGF catalog layer | KB, Memory, CLS, Personal Wiki, Capabilities Registry | Open classification decision: Governance sublayer vs. new Environment/Substrate Governance layer. |
| Boundary surfaces | Real but no catalog home | Slack, Telegram, BlueBubbles, Claude commands | Open classification decision: Security sub-concern vs. separate boundary-surfaces catalog. |

## Resolver entries (ADR-007 R5)

Structured per-project resolver entries with the 7-field R5 schema (path, owner,
stage, canonical-context-file, status-file, portfolio-row, freshness-threshold).
Seeded by the per-project contract pilots; added here as projects adopt the
contract. (Forge addition, 2026-05-25 — Pilot 1; pending Krypton review.)

| Project | path | owner | stage | canonical-context-file | status-file | portfolio-row | freshness-threshold |
|---|---|---|---|---|---|---|---|
| Capabilities Registry | `/Users/jessepike/code/_shared/capabilities-registry` | forge | Develop | `AGENTS.md` | `status.md` | Part A → Layer 2 (Operating-Methodology) → "Capabilities Registry" | 30 days |

## Part B — Confirmed workstreams

These are the real workstreams from Jesse's confirmed brief. "Owner" means current best-known owner or responsible set; several still need a single PM-style lead.

| # | Workstream | Projects touched | Owner / PM | In-flight now? | Current state | Next move |
|---|---|---|---|---|---|---|
| 0 | WM / task-management revision | `work-management`, `wm-agent`, `aws`, `krypton`, dashboard surface | CTO + Forge + Krypton + Jesse pieces; **single PM not assigned** | Yes / active priority | Defines the work/task spine: capture, routing, visibility, auditability, traceability, observability, automated jobs, dashboard POV. | Align architecture with AWS discussions; assign PM; define core artifacts and runtime/dashboard shape. |
| 1 | AWS governance refresh | `aws`, `ai-dev`, `capabilities-registry`, `agent-exec`, `memory` | Krypton + Forge | Active | Reconcile stale status/backlog with North Star, portfolio map, and workstream truth. | Krypton review this draft, then route concrete cleanup/update work through Forge where dev-system paths are involved. |
| 2 | Symlink cleanup | `aws`, `_shared/adf`, `_shared/agentic-work-system` | Forge | Not before token reset | Two temporary symlinks remain past original cleanup window. | Make sure Forge is aware; after 11pm Sunday 2026-05-24 token reset, verify references and remove through Forge. |
| 3 | Context substrate reconciliation | `personal-context`, `context`, potentially root artifacts like `CLAUDE.md` | **unknown PM** | Active/recent, needs focus | Need intent, architecture, owner/PM declaration, project map, resolver, and orientation artifacts so agents can merge/operate cleanly. | Design core artifact set and owner declaration pattern; decide merge/split model for `personal-context` and `context`. |
| 4 | Personal Context Phase 1 | `personal-context`, context-design inbox, career/identity/pike-infra context | **unknown PM**; Jesse authority, agents propose | Not yet implemented | Several threads need to be pulled together; architecture exists or is emerging. | Re-ground in personal-context architecture; implement Phase 1 core files, frontmatter, portability, audits, eval suite. |
| 5 | CLS router dogfood | `context`, maybe `personal-context` | **unknown PM** | New, not yet implemented | Router/dogfood concept is priority but not yet operationalized. | Start dogfood with activation/cache/audit tracking; decide registration relationship to `personal-context`. |
| 6 | Diagram Forge OSS launch | `diagram-forge`, AWS standards | Forge + CTO? | P1, not core right now | Launch blocked by key rotation and plugin path/distribution cleanup. | Keep P1; rotate keys, fix plugin path hardcoding, run fresh-machine smoke test when core substrate work is stable. |
| 7 | Agent-org cleanup / pike-agents | `pike-agents`, `agent-exec`, AWS ownership model | Forge + Krypton?; PM unresolved | Yes, active open session | New project work defining agent teams, roles, hierarchy, harnesses, and invocation model; must align with AWS. | Align with AWS project-owner/PM model; separate positioning knowledge from structural agent-org cleanup. |
| 8 | Knowledge/wiki operationalization | `knowledge-base`, `knowledge-capture`, `personal-wiki`, `memory`, `agent-exec` | Should fall under KB project owner; **owner unknown** | Not active core; P1/P2 | Wiki may be live but is not operationally used; KB/capture/wiki sync status unclear. | Assign KB owner; decide operational loop for KB/wiki; punt until priority stack allows. |
| 9 | Directory maintenance cadence | `_shared/**`, ADF audit tooling, AWS standards | unknown; likely Forge/Krypton split | Scratchpad / candidate | Jesse flagged need for owner, schedule, skill/job, and durability around directory maintenance. | Add to scratchpad/backlog after Krypton review; evaluate existing ADF audit tools and weekly schedule. |
| 10 | Agent Canvas app | unknown / not visible in current map | unknown | Unknown | Jesse flagged "Agent canvas app and get agents to use"; no filesystem row confirmed in this reconciliation. | Krypton should locate source of truth and decide whether it belongs in Agent-Org or Output. |
| 11 | Krypton personal-agent capabilities | `krypton`, `memory`, `kb`, channels, dashboard | Krypton | Priority #7 | Build out personal agent capabilities after foundational AWS/process work matures. | Define capability roadmap after WM/task spine and substrate health work are stable enough to support it. |

### Projects still lacking assigned PM/owner

- Knowledge Base
- Knowledge Capture
- Link Triage Pipeline
- Memory
- Personal Wiki / wiki operationalization
- Work Management / WM spine single PM
- Personal Context Phase 1
- Context Lifecycle Substrate / CLS dogfood
- Agent Exec / pike-agents structural cleanup
- Agent Canvas app
- Directory maintenance cadence

## Jesse's priority stack

1. Build the foundation for AWS, personal operating infrastructure, and the groundwork for how Jesse and agents prioritize, execute, and track work.
2. Clean up stale/bad jobs for token conservation and optimization.
3. Focus on CLS, Personal Context, and adjacent substrate work.
4. Build out work/task management capability.
5. Change workflow to adapt to new processes and ways of working.
6. Build out Marcus coach and explore the new interaction approach.
7. Build out Krypton personal-agent capabilities.
8. Get core substrate components healthy, updated, current-state/future-state/gap-aware: KB, Memory, and related substrate.

## AGF gaps surfaced

1. **Boundary surfaces lack a catalog home.** Slack, Telegram, BlueBubbles, Claude commands, and similar channels are real boundary surfaces, but AGF has no clear catalog layer for them.
2. **Substrate/environment may deserve its own AGF catalog layer.** KB, Memory, CLS, Wiki, and Capabilities Registry map to Primitive #19 but do not fit cleanly into the existing five AGF catalog layers.
3. **Trust Ladder is uncodified per agent.** Pike agents operate at different effective trust levels, but those declarations are not formalized.
4. **GDR emission is unbuilt at gate boundaries.** Krypton's propose-and-confirm gates exist; GDR-shaped emission does not.
5. **Decision Intelligence proper is unbuilt.** The corpus exists; RDG / Claims / Beliefs / Revision Cascade / Decision Memo do not.
6. **Tier 2 Orchestration Harness is absent.** Pike-agents call each other ad hoc; no ACLs, cross-agent budget allocation, or inheritance validation are in place.

## Portfolio gaps surfaced

1. **Project ownership is the binding gap.** Jesse's PM model is not yet encoded in most repos.
2. **Current-state docs are stale in key places.** AWS `docs/status.md`, agent-exec, personal-wiki, and others need refresh once this map is reviewed.
3. **Substrate is fragmented.** `personal-context`, `context`, KB, Memory, Wiki, Krypton, and capture paths need a declared boundary model.
4. **Dirty-tree drift clusters around strategic areas.** AWS, agent-exec, diagram-forge, personal-wiki, personal-context, and context were dirty in the sweep.
5. **Symlink aliases remain unresolved migration debt.** `_shared/adf` and `_shared/agentic-work-system` still exist as aliases.
6. **AGF alignment is mostly implicit.** AWS and CLS are explicit; many other rows need documented alignment or intentional exclusion.

## Next moves for Krypton review

1. Validate this reconciliation against Jesse's intent and correct owner/PM gaps.
2. Decide which workstreams need immediate Forge routing versus Krypton-owned planning.
3. Convert Jesse's priority stack into an operating sequence without over-expanding scope.
4. Confirm whether every active project needs a root owner/PM artifact and what its canonical filename should be.
5. Route symlink cleanup to Forge after the 11pm Sunday 2026-05-24 token reset window.
6. Decide whether KB/wiki operationalization is P1 or P2 and name the KB owner.
7. Decide whether substrate/environment should become an AGF catalog layer or stay under Governance.
8. Locate and classify Agent Canvas app.

## Update cadence

- Update on material portfolio change: component added, retired, owner assigned, workstream activated/paused, or state materially changed.
- Update on AGF doctrine change: primitive, layer, or vocabulary changes that affect classification.
- Use this as the first read for cross-project AWS/Krypton portfolio orientation.
- Do not re-derive from scratch unless the four-layer inventory is stale; update this file in place.
