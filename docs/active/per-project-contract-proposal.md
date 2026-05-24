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
| `CLAUDE.md` or `AGENTS.md` | Lean machine-context file | One should be canonical. It should name the PM/owner and define the orientation map. The other should be a pointer or mirror, not divergent context. |
| `README.md` | Human-facing overview | Verbose, HTML-renderable, suitable for people, not the agent's minimal context source. |
| `intent.md` or `docs/intent.md` | North Star | Already required by `project-layout.yaml`; why the project exists and what success means. |
| `status.md` or `docs/status.md` | Current state | Already required; should state freshness, active blockers, last meaningful session, and next sync target. |
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

## 6. Open Questions for Jesse

1. Should the owner declaration live in `CLAUDE.md` frontmatter, `AGENTS.md` frontmatter, a dedicated `PROJECT.md`, or the resolver?
2. Which file is canonical for machine context: `CLAUDE.md`, `AGENTS.md`, or "one canonical, one pointer" chosen per project?
3. Should `decisions.md` move from recommended to required for all active system projects?
4. Should `README.md` become required even for internal projects, or only for human-facing / shared projects?
5. What is the minimum resolver entry schema: path, owner, stage, context file, status file, portfolio row, freshness threshold?
6. What freshness threshold should trigger "state may be stale" warnings?
7. Who is assigned PM for currently unowned substrate projects: Knowledge Base, Knowledge Capture, Link Triage, Memory, Personal Wiki, Work Management, Personal Context, Context Lifecycle Substrate, Agent Exec / Pike Agents, Agent Canvas, and directory maintenance?
8. Can a project PM be an agent role such as Krypton or Forge, or must every project have Jesse as final owner with an agent as operating PM?
9. How should ownership interact with Forge-only dev-system paths, where Forge has write authority but another project PM may own product direction?
10. Should this become `project-layout.yaml` v1.2.0, a separate `project-contract.yaml` standard, or an ADR-backed convention first?

## Draft Design Session Prompt

Use this proposal to decide the smallest enforceable contract that answers:

- who owns the project;
- what an agent must read before acting;
- where stale state escalates;
- how the portfolio map and local project files stay aligned.

Do not convert this into a standard until Jesse chooses the owner-declaration mechanism and the canonical machine-context file policy.
