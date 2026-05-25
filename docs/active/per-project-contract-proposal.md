---
type: "proposal"
title: "Per-Project Contract + Assigned PM/Owner"
status: "draft-design-input"
updated: "2026-05-24"
owner: "unassigned"
standard-impact: "possible extension to project-layout.yaml after Jesse decision"
decision-status: "not decided"
---

# Per-Project Contract + Assigned PM/Owner Proposal

> DRAFT / design input for Jesse + Krypton. This is not a final standard, not an ADR, and not a decision. It proposes options for extending the existing AWS `project-layout.yaml` contract after review.

## 1. Problem

The recurring operational gap is not only stale documentation. It is that many projects do not clearly answer two first-order questions:

1. Who owns this project right now?
2. What exact artifacts must an agent ingest before acting?

When those answers are implicit, agents infer ownership from stale files, old project conventions, or adjacent project knowledge. That produces wrong routing, stale-state work, duplicated context loading, and avoidable assumptions.

The proposed fix is a per-project contract: each project exposes a small, standard artifact set and names one assigned PM/owner who holds current state, directs work, and is the sync target for agents.

## 2. Proposed Per-Project Core-Artifact Set

Baseline: extend the existing AWS `project-layout.yaml` standard. Do not replace it.

### Draft required set

| Artifact | Draft role | Notes / options |
|---|---|---|
| `CLAUDE.md` or `AGENTS.md` | Lean machine-context file | One should be canonical. It should name the PM/owner and define the orientation map. The other should be a pointer or mirror, not divergent context. | claude.md is cannonical, agents should refer to. i thought this was settled in our ADF specs.??
| `README.md` | Human-facing overview | Verbose, HTML-renderable, suitable for people, not the agent's minimal context source. |
| `intent.md` or `docs/intent.md` | North Star | Already required by `project-layout.yaml`; why the project exists and what success means. |  intent.md should be root. this needs to be part of cleanup so move to root for consistency. Claude.md and agents.md need to be resolvers.
| `status.md` or `docs/status.md` | Current state | Already required; should state freshness, active blockers, last meaningful session, and next sync target. |  status.md should be root. same as intent
| `BACKLOG.md` | Tracked work | Already required; should be used after orientation, not as the only state source. |
| `decisions.md` or `docs/decisions/` | Decision log | Currently recommended; proposal option is to require for active system projects. |
| `lessons.md` or `docs/lessons.md` | Recent learnings hot buffer | Already required; project-local gotchas and patterns before promotion. |
| `data/` | Project data or runtime state | Existing convention in several projects; proposal option is to standardize when a project has local stores, logs, exports, or generated state. |
| Canonical portfolio-map pointer | Cross-project ownership map | Each project should point to `/Users/jessepike/code/_shared/aws/docs/active/portfolio-map.md` or its eventual canonical replacement. |
| Resolver entry | Machine-locatable project registration | Each project should have a row or record in the portfolio/component resolver so agents can locate path, owner, stage, and canonical context file without guessing. |

### Lean machine-context file

Draft principle: the machine-context file should stay short. It should route an agent to the right artifacts rather than re-stating all of them.

Minimum draft fields:

- Project name and path.
- ADF stage.
- PM/owner.
- Sync target: who an agent should align with before material work.
- Canonical orientation sequence.
- Hard constraints and "do not modify" boundaries.
- Pointers to `intent.md`, `status.md`, `BACKLOG.md`, `decisions.md`, `lessons.md`, `README.md`, data/runtime locations, and portfolio map.

### Where PM/owner is declared

Option A: frontmatter in canonical machine-context file.

Example:

```yaml
---
type: "project-context"
project: "Nerve Center"
stage: "Operate"
owner: "krypton"
sync_with: "krypton"
updated: "2026-05-24"
portfolio_map: "/Users/jessepike/code/_shared/aws/docs/active/portfolio-map.md"
---
```

Tradeoffs:

- Pros: one fewer file; visible exactly where agents already orient; easy to lint; compatible with existing `CLAUDE.md` frontmatter in some projects.
- Cons: mixes project identity, agent instructions, and ownership metadata; awkward if both Claude and Codex need first-class canonical files; could make `CLAUDE.md` carry non-Claude semantics.

Option B: dedicated `PROJECT.md`.

Example:

```yaml
---
type: "project-contract"
project: "Nerve Center"
owner: "krypton"
sync_with: "krypton"
stage: "Operate"
canonical_agent_context: "CLAUDE.md"
human_readme: "README.md"
portfolio_map: "/Users/jessepike/code/_shared/aws/docs/active/portfolio-map.md"
resolver_id: "nerve-center"
updated: "2026-05-24"
---
```

Tradeoffs:

- Pros: clean separation between project contract and model-specific context; easier for any agent/tool to parse; avoids choosing Claude-vs-Codex semantics inside the ownership record.
- Cons: adds another root artifact; must be kept synchronized with `CLAUDE.md`/`AGENTS.md`; may feel heavier than needed for small projects.

Option C: resolver-first, with local pointer.

The portfolio/component resolver holds authoritative ownership and project metadata. Each project has only a short local pointer to that resolver entry.

Tradeoffs:

- Pros: one canonical cross-project registry; easier portfolio audits and owner sweeps.
- Cons: weaker local self-containment; if resolver is stale or unavailable, an agent landing in a repo still has to leave the project to answer "who owns this?"

Draft preference for discussion: Option A for immediate incremental rollout, with a resolver entry as the portfolio-level index. Consider `PROJECT.md` only if Jesse wants ownership metadata fully decoupled from model-specific files.

**RESOLVED (Krypton rec — see §6/R1): long-term shape = LOCAL TRUTH + GLOBAL INDEX.** Owner declared in `CLAUDE.md` frontmatter (local, self-contained, where agents already land); the resolver / portfolio-map is the global index that reconciles and audits. One write per project, reconciled up. No `PROJECT.md`.

## 3. PM/Owner Model

Draft definition: a project PM/owner is the single point of contact for project direction and state. This does not mean the owner writes all code or owns every implementation detail. It means the owner:

- Directs what the project is trying to do now.
- Holds or curates current state.
- Keeps `status.md` and orientation pointers trustworthy.
- Accepts or rejects proposed work.
- Routes cross-project questions to the right adjacent owner.
- Ensures stale state is corrected or explicitly marked stale.

Agent behavior should be deterministic:

1. Find the project's contract.
2. Read the declared owner / sync target.
3. Read the orientation set.
4. If state files are stale or contradictory, escalate to the owner or portfolio map rather than guessing.

This composes with the cross-session-visibility problem by making stale state visible as an ownership failure, not just a documentation failure. If `status.md` is old, the agent knows who to sync with and where the portfolio-level truth may live.

Open design point: "PM" may be a human, named agent, agent team, or role. The proposal should prefer exactly one accountable PM field even when supporting contributors are many.

## 4. Orientation Sequence

Draft sequence for the `orient` skill or equivalent project landing workflow:

1. Resolve project path and resolver entry.
2. Read the canonical machine-context file: `CLAUDE.md` or `AGENTS.md`.
3. Read `intent.md` / `docs/intent.md` for purpose and success criteria.
4. Read `status.md` / `docs/status.md` for current state, freshness, blockers, next steps, and owner sync instructions.
5. Read `BACKLOG.md` only after current state is understood.
6. Read `decisions.md` or `docs/decisions/` for accepted constraints relevant to the task.
7. Read `lessons.md` for recent local gotchas.
8. Read `README.md` when human-facing behavior, install/use instructions, or public documentation matter.
9. Check `data/`, runtime state, job registries, or generated outputs only when the task touches operation, observability, or persistence.
10. Check the portfolio map for owner conflicts, project boundary questions, or cross-project workstream context.

Staleness rule option: if `status.md` is older than a project-defined freshness threshold, the agent should report that before making material changes. For active system projects, a draft threshold could be 14-30 days, but Jesse should decide by project class.

## 5. Migration

Do this incrementally. No big-bang rewrite.

Draft rollout:

1. Use the portfolio map as the migration queue.
2. Start with active and ambiguous substrate projects: Work Management, Personal Context, Context Lifecycle Substrate, Knowledge Base, Memory, Knowledge Capture, Link Triage, Personal Wiki.
3. For each project, add or normalize the owner declaration in the chosen place.
4. Normalize the lean machine-context file so it names the owner and points to the standard artifacts.
5. Add or update the resolver entry.
6. Mark stale or contradictory files explicitly instead of silently rewriting history.
7. Run a lightweight project-layout audit after each project.
8. Only after 2-3 projects validate the pattern, route an AWS standard update through Forge and ADR process.

Migration should not require every project to be perfect before the model helps. The minimum useful unit is:

- one owner field;
- one canonical machine-context file;
- one current-state file;
- one resolver entry;
- one portfolio-map pointer.

## 6. Recommended Decisions (Krypton) — approve or veto each

**Model (answers Jesse's two direct questions):**
- **No custom agent per project.** Custom agents are reserved for distinct personas/products (Krypton, Marcus). A project's PM is an *existing* domain agent. 14 bespoke PM agents = more fragmentation + maintenance, against lean-harness.
- **One agent owns many projects because PM ≠ doer.** The PM directs + holds state + accepts/rejects work; implementation delegates to sub-agents/Codex. Multi-project ownership is therefore tractable.
- **Two-tier ownership:** Jesse = principal/ultimate owner; the assigned agent = operating PM (single point of contact). ok. agree with ownership being single PM across groups of projects. Let's assign PMO agent as owner. what needs to happen to support that both at the PMO agent harness level and the individual project level?

| # | Question | Recommendation |
|---|----------|----------------|
| R1 | Where is owner declared? | **`CLAUDE.md` frontmatter `owner:` field (local truth) + resolver/portfolio-map (global index).** No `PROJECT.md`. Long-term shape = local-truth + global-index: one write per project where agents already land, reconciled up. | agree
| R2 | Canonical machine-context file? | **CORRECTION — this was already "settled," contradictorily.** `project-layout.yaml` calls AGENTS.md a *"Codex mirror of CLAUDE.md"* (CLAUDE primary); but ADF-MULTI-RUNTIME-SPEC + ADF-ARCHITECTURE-v3 say **AGENTS.md = source of truth, CLAUDE.md imports `@AGENTS.md`** (AGENTS primary). They conflict — that's why it felt unsettled. **Krypton rec: conform to the multi-runtime spec → AGENTS.md canonical, CLAUDE.md imports it** (AGENTS.md is the open standard for Codex/Gemini/Cursor/+20 tools; CLAUDE-primary serves only Claude). This reverses Jesse's in-doc edit + my prior R2 — **needs Jesse's call.** Then Forge fixes the contradicting `project-layout.yaml` line + the specs reconcile via ADR. | agree
| R3 | `decisions.md` required for active projects? | **Yes, required** for active system projects (cheap; it's the Memory-feed convention). | agree. per project decision ledger. let's confirm that the harness is in place to ensure consistent utility.
| R4 | `README.md` required for internal projects? | **No — required only for human-facing/shared projects.** Optional internal. No busywork. | ok. so claude.md is the project cannonical source of truth? Single the one artifact that every agent would begin with for orienting on that project? Is it resolver pointing to other sources? Do we need to change our AWS and ADF rules for claude.md?
| R5 | Minimum resolver entry schema? | **path, owner, stage, canonical-context-file, status-file, portfolio-row, freshness-threshold** (those 7). |agree
| R6 | Freshness threshold for stale warning? | **30 days** for active system projects (single default; tune per-class later). | how do we support to ensure this happens? what's the process? scheduled review? review what, do what? 
| R7 | PM assignments for unowned projects | **Forge:** aws, capabilities-registry, ai-dev, pike-agents, agent-exec, diagram-forge, directory-maintenance. **CTO:** nerve-center, pike-dashboard, work-management + wm-agent (the spine — single PM = CTO, Forge+Krypton contribute), agent-canvas. **Krypton:** knowledge-base, knowledge-capture, memory, link-triage, personal-wiki, personal-context, context, krypton. (Krypton also holds portfolio oversight — tracks owners, isn't PM of everything.) |why would CTO own NC vs Forge? I think we need some discussion on what CTO should own. why would krypton own kb, memory, link triage etc.? i feel krypton should own personal context. I don't have strong opinions on a lot of this ownership as I still want to explore the best options. We probably should have a model or rubric to help guide.
| R8 | Can PM be an agent role? | **Yes — Jesse = principal; agent = operating PM.** Two-tier, always. | Should we just use our current PMO agent as the PM or a subordinate or separate?
| R9 | Ownership vs Forge-only dev-system paths? | **Different axes.** PM owns *direction*; Forge keeps *write-authority* on dev-system paths. Non-Forge PM routes dev-system changes to Forge (existing rule). No conflict. | Yes PM is different role than forge. 
| R10 | Standard form? | **ADR-backed convention first → pilot on 2-3 projects → fold into `project-layout.yaml` v1.2.0.** No separate standard. | unsure what's meant here by ADR backed conventions.

> These are recommendations to approve/veto, not re-open. Veto any line and I'll revise; silence on a line = approved. On approval, the PM assignments (R7) get stamped into each project's `CLAUDE.md` owner field via Forge, and R1–R10 route to an ADR.

## Draft Design Session Prompt

Use this proposal to decide the smallest enforceable contract that answers:

- who owns the project;
- what an agent must read before acting;
- where stale state escalates;
- how the portfolio map and local project files stay aligned.

Do not convert this into a standard until Jesse chooses the owner-declaration mechanism and the canonical machine-context file policy.

## 7. Decision status + responses to Jesse's inline edits (2026-05-25)

**Locked (agreed):** R1, R3, R5, R9. **R2 DECIDED → AGENTS.md = source of truth; CLAUDE.md imports `@AGENTS.md` and carries Claude-specific rules** (Claude stays the primary coding model). Model: single PM across *groups* of projects = agreed.

**Clarifications you asked for:**
- **R4 — is CLAUDE.md the canonical source?** No — **AGENTS.md is canonical source**; CLAUDE.md imports it + adds Claude-specifics. The per-project orientation entry point is that canonical context file, acting as a **resolver/manifest** pointing to intent/status/BACKLOG/decisions/lessons/README/data + portfolio map. **Yes, this requires updating AWS `project-layout.yaml` (its "AGENTS.md = mirror of CLAUDE.md" line) and reconciling the ADF specs** — a Forge + ADR task.
- **R10 — what's an "ADR-backed convention"?** Rather than editing the `project-layout.yaml` standard immediately, first record the decision as a numbered **ADR** (governed, dated, reversible). Pilot on 2-3 projects. Only after it's proven, fold into `project-layout.yaml` v1.2.0. ADR first = low-risk; standard-edit last = durable.

**Open threads — picked up in parallel NOW (Codex):**
- **R7 ownership rubric** — agreed my picks were ad-hoc. Codex is drafting an **ownership rubric** (dimensions: domain fit, who-consumes-it, ADF stage, write-authority) and re-deriving owners *by the rubric* for your review. **Locked per your note: Krypton → personal-context.** Everything else re-derived, not asserted.
- **R3 + R6 enforcement** ("is the harness in place? how do we ensure freshness happens?") — Codex is **auditing existing tooling** (project-doctor, ADF-audit scripts, NC freshness/lint jobs) to map what already enforces the contract (owner field, decision ledger, staleness) vs the gaps + how to wire them. Execution/durability, not new design.
- **R8 PMO agent** — you referenced "our current PMO agent." **Clarification: there is no PMO agent in the roster today** (CTO/CFO/CPO/CRO/CISO/CMO/Forge/Krypton/Tools). Options after the rubric: (a) stand up a dedicated PMO agent owning project-PM across groups; (b) PM as a *function* existing domain agents carry; (c) Krypton-as-PMO for coordination-layer projects. Decide after the rubric — it tells us whether one PMO can span all projects or PM must distribute.

**Your Model question (harness vs project support for PMO-as-owner):** project level = `owner:` field names the PM; harness level = the PM agent's **state file carries an owned-projects index** it scans on orient (this doubles as the cross-session-visibility fix). The rubric thread firms this up.
