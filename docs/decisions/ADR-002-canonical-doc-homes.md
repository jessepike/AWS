---
adr: 002
title: Canonical Doc Homes for Cross-Cutting Infrastructure
date: 2026-04-13
status: accepted
owner: Forge
supersedes: []
related: [ADR-001]
---

# ADR-002: Canonical Doc Homes for Cross-Cutting Infrastructure

## Context

Cross-cutting infrastructure components — Nerve Center, Krypton,
Memory, Knowledge Base, Capabilities Registry — have documentation that
spans multiple concerns: governance/intent, design, runbooks, live
deployment facts, and in some cases workbench output from sprints. Left
unmanaged, this documentation scatters:

- Governance content gets duplicated into workbench notes and never
  deleted
- Deployment facts get written into design docs and go stale when the
  deployment changes
- Sprint handoffs live next to canonical specs and readers can't tell
  which is authoritative
- The same concept (e.g. "what is NC") ends up partially written in
  3-5 places, each drifting independently

The NC docs consolidation sprint (2026-04-13) surfaced a concrete example:
NC governance/intent was split across a thin AWS brief, two workbench
docs in `tools/ai-dev/docs/active/`, and five Railway-era deployment
docs — none of which were cleanly canonical, all of which referenced
each other, and three of which had stale deployment assumptions baked in.

The fix is not better hygiene per doc. The fix is a rule: every
cross-cutting topic has **one** canonical home, everywhere else points to it.

## Decision

**Cross-cutting infrastructure components get one canonical doc home
per topic. Everywhere else gets a pointer, never a copy.**

### Topic → canonical location mapping

| Topic | Canonical home | Why |
|---|---|---|
| **Governance / intent** (what the component is, why it exists, its fit in AWS rings/layers, responsibilities, design principles) | `~/code/_shared/aws/docs/{component}-brief.md` | Governance content is AWS-owned. Forge writes it. It must stay stable across component redeployments. |
| **Code, design, runbooks, operational state** | The component's own repo under `_shared/{component}/docs/` | This content belongs with the code it describes. It changes when the code changes. |
| **Live job inventory** (what runs where, with what cadence, on what host) | `~/code/_shared/agent-exec/docs/jobs-registry.yaml` | Single authoritative cross-host registry. Do not duplicate into component docs. |
| **Capability entries** (registration, metadata, version, quality) | `~/code/_shared/capabilities-registry/capabilities/.../capability.yaml` | Single catalog drives discovery. |
| **ADRs that cross components** | `~/code/_shared/aws/docs/decisions/` | Cross-cutting decisions are AWS-level. |
| **Component-internal decisions** | `{component}/docs/decisions/` or `{component}/docs/adf/` | Scoped to the component's own lifecycle. |

### Rules

1. **One canonical doc per topic.** Anything else that references the
   topic must be a pointer (a short link with a one-line context),
   never a copy of the content.
2. **Workbench output is ephemeral.** Sprint handoffs, reviews, and
   analysis docs produced during a sprint get archived to the project's
   `.archive/` once their content lands in a canonical home. They do
   not persist in `docs/active/` indefinitely.
3. **If a topic doesn't have a canonical home yet, create one before
   writing about it in two places.** Adding the canonical-home doc is
   part of the first write, not a cleanup task.
4. **Changing the canonical home requires an ADR.** Moving governance
   content from AWS into a component repo (or vice versa) is a
   governance decision.
5. **Forge reconciles drift.** When two docs on the same topic
   disagree, Forge updates the canonical home and collapses the
   duplicates to pointers.

### Allowed patterns

- A component's `docs/` may contain a one-paragraph "what this is" at
  the top of its README — as long as it ends with a pointer to the
  AWS brief as the canonical source.
- An AWS brief may summarize runtime facts — as long as it points to
  the jobs registry / component docs for the authoritative version and
  does not duplicate anything that changes on redeployment.
- Sprint docs may capture decisions in flight. Once the sprint ends,
  the decisions either land in an ADR (cross-cutting) or in a
  component ADR (local), and the sprint doc is archived.

### Disallowed patterns

- Writing the same governance statement in two places "for discoverability"
- Leaving a workbench handoff in `docs/active/` after its content has
  been absorbed into a canonical doc
- Embedding deployment facts (host, port, cadence) in a governance
  brief when those same facts live in the jobs registry
- Creating a new top-level doc on a topic that already has a canonical
  home, even under a different name

## Consequences

**Positive:**
- Readers know exactly where to look for each kind of content
- Drift has a single place to update
- Governance content survives redeployment churn
- Workbench output has a clear end state (archive) so `docs/active/`
  stays genuinely active
- Forge's reconciliation scope is bounded

**Negative / risks:**
- Pointer chains can feel indirect when searching. Mitigated by keeping
  the mapping table (above) short and memorable.
- Requires discipline to archive workbench docs rather than letting them
  persist. Mitigated by including archive step in session-wrap checklist
  (backlog).

## Enforcement

Soft-rule today. Forge's audit mode checks for:

- AWS briefs older than their corresponding component's last major change
- `docs/active/` entries older than 30 days
- Duplicate governance statements across briefs and component docs
- Deployment facts in governance briefs that contradict the jobs registry

Hard enforcement via hook is backlog work.

## Related decisions

- **ADR-001:** AWS governance activation (established Forge as write authority for AWS components)

## References

- NC docs consolidation sprint (2026-04-13) — original forcing function
- `~/code/_shared/aws/docs/nerve-center-brief.md` — first canonical brief written under this rule
- `~/code/_shared/agent-exec/docs/jobs-registry.yaml` — live inventory (do not duplicate)
