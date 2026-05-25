---
type: "ownership-rubric"
title: "Project Ownership Rubric — Agentic Work System"
status: "draft-for-jesse-krypton-review"
updated: "2026-05-25"
owner: "unassigned"
reviewers:
  - "jesse"
  - "krypton"
source_context:
  - "/Users/jessepike/code/_shared/aws/docs/active/portfolio-map.md"
  - "/Users/jessepike/code/_shared/aws/docs/active/per-project-contract-proposal.md"
  - "/Users/jessepike/code/_shared/pike-agents/"
  - "/Users/jessepike/code/_shared/agent-exec/"
---

# Project Ownership Rubric — Draft

Draft for Jesse + Krypton review. This is not a decision record and should not be stamped into project files until reviewed.

## Purpose

Assign one operating PM/owner per system project without inventing one-off project PM agents or relying on ad-hoc guesses.

Model constraints:

- Jesse is the principal owner.
- The assigned agent is the operating PM: it holds state, directs work, accepts or rejects proposed work, and routes implementation.
- The PM owns a group of projects, not a single repo.
- PM does not mean doer. Implementation can route to Codex, Forge, CTO, or other agents.
- `AGENTS.md` is the canonical project context.
- Forge write authority over dev-system surfaces remains a hard boundary.
- Locked assignment: **Krypton owns `personal-context`**.
- Current roster: CTO, CFO, CPO, CRO, CISO, CMO, Forge, Krypton, Tools. No PMO agent exists today.

## Candidate Agent Domains

Use the actual agent charters, not intuition:

| Agent | Ownership domain signal |
|---|---|
| Krypton | Chief of Staff; cross-system intelligence, prioritization, activity synthesis, operational decisions, briefings, work/status synthesis, personal-agent layer. |
| Forge | Development-system engineer; skills, agents, plugins, workflows, session lifecycle, ADF specs, `AGENTS.md`/`CLAUDE.md`, shell/config, capabilities registry. |
| CTO | Portfolio technology architecture; system design, integration coherence, technical debt, build-vs-buy, shared infrastructure architecture. |
| Tools | Infrastructure diagnostics; MCP health, plugin validation, agent registration diagnostics, environment/config health. |
| CPO | Product strategy, PMF, roadmap, feature scoping, stage gates. |
| CISO | Security architecture, threat modeling, compliance, incident/trust review; read-only by default. |
| CFO | Financial data integrity, unit economics, pricing arithmetic, capital and budget health. |
| CRO | Revenue strategy, GTM, conversion, retention, pricing execution. |
| CMO | Positioning, messaging, category design, content, launch narrative. |

For this AWS system-project set, most candidates are Krypton, Forge, CTO, and Tools. CPO/CISO/CFO/CRO/CMO are review or advisory owners unless a project is specifically product, security, finance, revenue, or marketing centered.

## Rubric

Score each candidate 0-3 on each weighted dimension. Maximum score is 30.

| Dimension | Weight | Score 0 | Score 1 | Score 2 | Score 3 |
|---|---:|---|---|---|---|
| Domain fit | 3 | Outside charter | Adjacent charter | Material part of charter | Core charter |
| Consumer dependency | 2 | Does not consume it | Occasional consumer | Regular consumer | Cannot function well without it |
| Lifecycle fit | 1 | Mismatched to project stage | Advisory fit only | Can direct current stage | Natural owner for current stage |
| Write authority / execution path | 2 | Cannot route work safely | Needs frequent handoff | Can route most work | Has direct authority or explicit routing path |
| Coordination vs domain layer | 2 | Wrong altitude | Only local component view | Can manage project boundary | Best owner of cross-project boundary |

Scoring notes:

- Domain fit asks: "Is this project about the agent's charter?"
- Consumer dependency asks: "Which agent is impaired if this project is stale or broken?"
- Lifecycle fit asks whether the current ADF stage needs architecture, operations, product, governance, or tooling ownership.
- Write authority does not override PM ownership, but it matters. A non-Forge PM can own direction for a dev-system project only if the work can safely route through Forge.
- Coordination vs domain layer prevents assigning a broad coordination artifact to a narrow technical specialist, or a technical toolchain artifact to a pure synthesizer.

## Tie-Breaks

1. Hard constraints win first: locked assignments and Forge-only write-authority surfaces.
2. If one agent scores higher in both domain fit and consumer dependency, choose that agent.
3. If the project is a coordination/state surface consumed by multiple agents, prefer Krypton unless write-authority makes Forge the safer PM.
4. If the project is a development-system artifact, prefer Forge unless it is primarily architecture strategy rather than tooling/config.
5. If the project is shared technical infrastructure with no single agent as primary consumer, prefer CTO.
6. If Tools vs Forge ties, choose Forge for creation/evolution and Tools for health/diagnostics only.
7. If two candidates remain within 2 points and the loser has a materially different failure mode, mark as "options" instead of pretending the rubric decided.

## Applied Assignment

### Layer 1: Substrate

| Project | Proposed PM/owner | Confidence | Rubric rationale |
|---|---|---:|---|
| Knowledge Base | Krypton, option: CTO | Medium | Krypton has the strongest consumer dependency because briefings, focus, digest, and status synthesis depend on KB; CTO has technical domain fit for KB architecture, but not the operating-state consumer pull. |
| Knowledge Capture | Krypton, option: CTO | Medium | Capture is a feeder into Krypton's intelligence layer; CTO is plausible for pipeline architecture, but ongoing PM should sit with the agent that needs captured signal to stay useful. |
| Krypton | Krypton | High | Self-owned chief-of-staff runtime; domain fit and consumer dependency both max out. |
| Link Triage Pipeline | Krypton, option: CMO | Medium | The pipeline feeds attention and knowledge routing, so Krypton wins consumer dependency; CMO becomes plausible if the pipeline is reframed as market/content intelligence rather than operating context. |
| Memory | Krypton, option: CTO | Medium | Krypton consumes Memory for cross-session continuity and synthesis; CTO is a strong architecture owner for the memory layer, but not the best operating PM unless the work is primarily redesign. |
| Nerve Center | CTO, option: Krypton | Low-Medium | CTO fits observability architecture and operational failure modes; Krypton consumes findings and status. If NC becomes primarily the portfolio "what matters" feed, Krypton should own; if it remains observability infrastructure, CTO should own. |
| Personal Wiki | Krypton, option: CMO | Low-Medium | Wiki is personal/knowledge synthesis substrate, so Krypton is the natural consumer; CMO only fits if the wiki becomes a publishing/narrative surface. |
| Pike Dashboard | CTO, option: Krypton | Low-Medium | Dashboard is an operator cockpit and observability surface; CTO fits system architecture, Krypton fits synthesis consumption. Decide based on whether it is a technical cockpit or Jesse-facing command surface. |
| Work Management Agent | Krypton, option: CTO | Medium | The agent spec says wm-agent is deterministic workflow state while Krypton owns reasoning and composition; Krypton is the strongest consumer, CTO is plausible for execution-spine architecture. |
| Work Management | Krypton, option: CTO | Low-Medium | Active WM spine exists to preserve cross-project continuity for Krypton/Jesse; Krypton wins coordination and consumer dependency, CTO wins architecture. This is a real tie if the next phase is mostly system design. |
| Personal Context | Krypton | Locked | Locked by Jesse. Also matches personal-agent context, synthesis, and chief-of-staff continuity. |
| Context Lifecycle Substrate | Krypton, option: CTO | Medium | CLS activation/cache/audit exists to make Krypton context-aware; CTO is plausible for substrate architecture, but Krypton has higher consumer dependency. |
| Hermes Deploy | Krypton | Medium | Deprecated runtime is superseded by Krypton, so ownership is decommissioning/transition under the successor system rather than new technical build. |

### Layer 2: Operating-Methodology

| Project | Proposed PM/owner | Confidence | Rubric rationale |
|---|---|---:|---|
| AWS | Krypton + Forge split; proposed PM: Krypton, write authority: Forge | Medium | AWS is coordination/governance state consumed by Krypton, while updates to standards, specs, and dev-system surfaces route through Forge. If one field is required, Krypton owns direction and Forge owns implementation authority. |
| ADF | Forge, option: CTO | Medium | ADF specs and project-layout rules are Forge's charter; CTO is advisory for architectural coherence but not the best PM for spec maintenance. |
| Agentic Work System Alias | Forge | High | Symlink/migration artifact inside the dev-system/governance surface; write-authority and domain fit both point to Forge. |
| Capabilities Registry | Forge | High | Explicit Forge domain: capabilities registry, skills/tools catalog, deployment and discoverability. Domain fit and write authority both max out. |
| Shared Claude Config | Forge | High | Claude/Codex config, `CLAUDE.md`, `AGENTS.md`, settings, hooks, and shell configuration are Forge-owned dev-system surfaces. |
| Agent Harness | Forge, option: CTO | Medium | Harnesses are dev-system tooling, so Forge owns build/evolution; CTO is needed for architecture review if the harness defines cross-system contracts. |
| AI Dev | Forge | High | Explicit Forge domain: development-system tooling, workflows, skills, agents, config, and ADF support. |
| CC Codex Handoff | Forge | High | Multi-model workflow bridge and session handoff tooling are Forge's workflow/dev-system domain. |

### Layer 3: Agent-Org

| Project | Proposed PM/owner | Confidence | Rubric rationale |
|---|---|---:|---|
| Agent Exec | Forge, option: Krypton | Medium | Agent Exec is persistent context for executive agents and agent-boundary structure; Forge owns agent system structure, while Krypton consumes and orchestrates exec outputs. PM should be Forge unless the work is mostly portfolio routing policy. |
| Pike Agents | Forge, option: Krypton | High | Agent definitions, prompts, tools, model assignment, and sync/deploy are explicitly Forge-owned. Krypton is a consumer/orchestrator, not the owner of agent definitions. |

### Layer 4: Output

| Project | Proposed PM/owner | Confidence | Rubric rationale |
|---|---|---:|---|
| Diagram Forge | Forge, option: CTO or CPO | Low-Medium | As an MCP/plugin/tooling product, Forge has the strongest write-authority and tooling fit; CTO is plausible for architecture/productization quality; CPO becomes relevant only if OSS launch/product strategy is the binding work. |

## Assignment Spread

Proposed primary PM distribution:

| Agent | Projects |
|---|---|
| Krypton | Knowledge Base, Knowledge Capture, Krypton, Link Triage Pipeline, Memory, Personal Wiki, Work Management Agent, Work Management, Personal Context, Context Lifecycle Substrate, Hermes Deploy, AWS direction |
| Forge | ADF, Agentic Work System Alias, Capabilities Registry, Shared Claude Config, Agent Harness, AI Dev, CC Codex Handoff, Agent Exec, Pike Agents, Diagram Forge, AWS implementation authority |
| CTO | Nerve Center, Pike Dashboard |
| Tools | None as PM; diagnostic/health contributor |
| CPO/CISO/CFO/CRO/CMO | None as PM in this system-project set; review/advisory by domain when needed |

This spread is skewed toward Krypton and Forge because the project set is mostly coordination substrate plus development-system infrastructure. It does not imply CPO/CISO/CFO/CRO/CMO are weak agents; it means this inventory is not mostly product, security, finance, revenue, or marketing work.

## PMO Question Input

The assignment does not strongly support one PMO agent owning all groups today.

Evidence:

- The top-scoring projects split into two natural groups: **Krypton-owned operating context/intelligence substrate** and **Forge-owned dev-system/tooling substrate**.
- Several projects need Forge write authority even when Krypton should own direction (`AWS`, possibly `Work Management`, possibly `Agent Exec`).
- CTO remains a better owner than a generic PMO for observability/infrastructure surfaces when the binding risk is architecture and operational failure, not portfolio continuity.
- Tools is a health/diagnostic function, not a PM function.
- A PMO agent would either duplicate Krypton's coordination charter or blur Forge's hard dev-system boundary.

Realistic options:

| Option | Shape | Pros | Cons |
|---|---|---|---|
| A. No PMO agent; distributed PM by rubric | Krypton owns operating context; Forge owns dev-system; CTO owns infrastructure architecture surfaces. | Matches current charters; minimal new harness; respects write boundaries. | Krypton may carry many substrate projects; requires good owner index and freshness reviews. |
| B. PMO as a function inside Krypton | Krypton keeps portfolio owner index, freshness cadence, and cross-owner review, but project PMs remain distributed. | Uses existing Chief of Staff charter; avoids new agent. | Needs explicit guardrail that Krypton is not PM of everything. |
| C. New PMO agent | PMO owns owner index, review cadence, stale-status sweeps, and escalation, while domain agents own project direction. | Clear governance role if ownership audits become heavy. | No current roster seat; risks becoming a coordination layer that duplicates Krypton without domain authority. |
| D. PMO owns all projects | One agent is operating PM for every system project. | Simple on paper. | Rubric evidence argues against it: dev-system write authority, technical architecture ownership, and personal-context/Krypton continuity pull in different directions. |

Draft recommendation for review: **Option B first, Option A at the project level.** Treat PMO as a Krypton-held portfolio function, not a new PM agent and not a universal project owner. Revisit a dedicated PMO only if the owner index, freshness cadence, and escalation workflow become too heavy for Krypton.

## Open Decisions

1. Does Jesse want `Nerve Center` and `Pike Dashboard` owned by CTO because they are observability infrastructure, or Krypton because they are consumed as command/synthesis surfaces?
2. Does `Work Management` become Krypton-owned because its purpose is continuity, or CTO-owned during the architecture-heavy rebuild phase with transfer to Krypton at Operate?
3. Should `Knowledge Base`, `Memory`, and `Knowledge Capture` be grouped under Krypton now, or temporarily CTO-owned until substrate architecture is stabilized?
4. Does `Diagram Forge` currently need Forge ownership for plugin/tooling launch cleanup, or CPO/CTO ownership for OSS product launch strategy?
5. Should AWS owner be recorded as one field (`Krypton`) plus `write_authority: Forge`, or as a split owner field (`Krypton + Forge`) until the standard supports separate axes?
