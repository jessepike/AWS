---
adr: 005
title: AGF Alignment — AWS as a Dogfooding Instance / First Reference Implementation
date: 2026-05-24
status: accepted
owner: Forge
ratifiers: [Krypton, Jesse, agf-architect]
ratification_date: 2026-05-31
ratification_provenance: "agent-canvas decision-set adr005-ratify-2026-05-30"
supersedes: []
related: [ADR-001, ADR-004]
---

# ADR-005: AGF Alignment — AWS as a Dogfooding Instance / First Reference Implementation

> **Status: ACCEPTED.** Ratified 2026-05-31 by Krypton, Jesse, and agf-architect
> via agent-canvas decision-set `adr005-ratify-2026-05-30`.

## Context

The Agentic Governance Framework (AGF, `~/code/clients/risk/AGF/`) is Keating
Pike's commercial governance framework. Until now, AWS's stance toward AGF has been
**inspiration-only**: `aws/docs/overview.md` explicitly treats AGF as a source of
ideas, not a framework AWS conforms to. AGF was developed largely in the abstract.

Two facts make that stance worth reversing:

1. **AGF needs evidence.** A governance framework that has never governed a real
   agentic system is untested doctrine. AWS is a live, multi-agent, multi-model
   operating system with real observability (Nerve Center / Pike Dashboard), real
   agent harnesses, real human-oversight gates, and real audit surfaces. It is the
   most honest available test bed for AGF.
2. **AWS needs a governing frame.** AWS is design-rich but operationalization-poor;
   its components were each designed well but never tied to a single governance
   model. AGF is exactly such a model. The two needs are complementary.

The `agf-applied/` catalog (`~/code/clients/risk/agf-applied/`, private repo) was
stood up to hold reference implementations by AGF layer. It is the structural home
for this alignment work; the portfolio map is its keystone artifact.

## Decision

**AWS adopts AGF alignment as a first-class goal: AWS becomes a dogfooding
instance / first reference implementation of AGF, in order to validate,
invalidate, and improve AGF.** This reverses the inspiration-only doctrine in
`overview.md`.

Concretely:
- Every AWS component is classified against an AGF layer (observability, security,
  governance, decision-intelligence, agent-harnesses) — or flagged as an honest
  AGF gap. **Non-mapping is never silent:** either change the work, or file an AGF
  gap. (This is already Krypton's catalog discipline; this ADR makes it AWS-wide.)
- The **portfolio map** (`agf-applied/portfolio-map.md`, to be promoted to
  `aws/docs/active/portfolio-map.md`) is the standing artifact that holds the
  classification and drives quarterly elevation.
- Findings flow **both ways**: where AWS practice contradicts or strains AGF, that
  is AGF evidence (a gap, an over-specification, a missing primitive) routed to
  agf-architect — not silently worked around.
- An **AGF evidence schema** (what counts as validation / invalidation / improvement
  signal, and how it's recorded) is a Foundation prerequisite, owned by
  agf-architect with CTO. The spine logs handoffs as governed boundaries that
  double as AGF evidence. **[Amendment B]** Evidence is scoped to the v1 schema
  record shape defined in Resolved Q1 below — not "every log line."

## Amendments (ratification, 2026-05-31)

From agf-architect's ratification review; all three applied above and in Consequences.

- **A — Positioning:** "dogfooding **instance** / first reference implementation,"
  NOT "*the* reference implementation." AGF is vendor-neutral; AWS is one topology
  (single-host, single-operator). Avoids implying AGF privileges it. (Applied to
  ADR title frontmatter, H1 heading, and decision prose above.)
- **B — Scope evidence to the schema:** "the spine logs handoffs as governed
  boundaries that double as AGF evidence" is bound to the 8-field evidence schema
  in Resolved Q1 — evidence is scoped to that record shape, not "every log line."
  (Applied to Decision bullet above.)
- **C — Adversarially solicit invalidation (new Consequence):** a **quarterly
  floor** on invalidation/improvement signals is in effect; "0 this quarter" must
  be an explicit, defended statement, not silence. Counters the
  author-dogfoods-own-framework → over-validate failure mode (AGF's own Adversarial
  Critique #4, applied reflexively). (Added to Consequences below.)

## Consequences

- `overview.md` must be corrected to reflect the reversed doctrine (currently states
  inspiration-only; also carries stale drift — lists dead work-management as the
  spine and an absorbed "tools" agent). De-drift tracked in Forge backlog.
- This is a Krypton-coordinated, multi-session program, not a Forge build. Sequence
  per Krypton's charter: **Foundation (integration-gap cleanup + AGF evidence schema)
  → Spine + Handoff → Krypton activation → NC remediation arm → Dashboard → Registry**,
  with AGF overlaying everything.
- Risk to manage: alignment-as-paperwork. Mitigation — the build constraint from
  Krypton's charter applies: thin vertical slices, each net-friction-reducing on its
  own; if a slice doesn't reduce friction or produce real AGF evidence, stop and rethink.
- **[Amendment C]** Quarterly floor on invalidation/improvement signals: "0 this
  quarter" must be an explicit, defended statement — not silence. Counters the
  author-dogfoods-own-framework → over-validate failure mode (AGF's own Adversarial
  Critique #4, applied reflexively).

## Resolved ratification questions

All five ratification decisions resolved via agent-canvas decision-set
`adr005-ratify-2026-05-30` on 2026-05-31. Ratifiers: Krypton, Jesse, agf-architect.

### Q1 — AGF evidence schema (adopted: embed v1 schema)

**Resolution:** Adopt the v1 evidence schema as a thin overlay on the existing spine
ledger. Recorded in-ADR now; promote to a referenced spec when the spine build pulls
it (thin-slice principle per the build constraint above). Design rationale: AGF already
ships the substrate — the Event Envelope (Primitive #10), the GDR schema, the
append-only `ledger.jsonl` the spine writes anyway. A logged handoff is already a
governed boundary. Evidence is a thin overlay on records the spine produces regardless
— zero new storage, zero new pipeline. The overlay is appended to the existing ledger
entry:

```yaml
agf:
  signal_type: validation | invalidation | improvement   # required — the one judgment call
  ring: R0 | R1 | R2 | R3                                  # required — where the boundary sat
  primitive_refs: [7, 14, 8]                               # required — primitives exercised (>=1)
  claim_ref: "agentic-primitives.md#bounded-agency"        # required for invalidation/improvement
  observation: "Hop-cap enforced in harness, not prompt"   # required — 1-2 sentences
  confidence: established | informed | open                # required — dogfoods the gradient
  gdr_ref: GDR-2026-0530-009                               # optional — iff the boundary was a decision
  disposition: open | routed | resolved                    # required — lifecycle (default open)
```

Six required fields. A boundary "counts" as evidence when it carries `signal_type`,
`ring`, >=1 `primitive_ref`, `observation`, `confidence`. The rest is reused from the
ledger entry.

**Signal discriminators:**
- *validation* = a primitive's predicted control held under real load, unforced.
- *invalidation* = a primitive's prediction failed / a ring or vocabulary assignment
  doesn't hold — **must carry a `claim_ref` naming the AGF assertion it falsifies**
  (no claim pointer → it's an *improvement*, not an invalidation).
- *improvement* = AGF is silent (gap) or over-specifies ceremony the spine proved
  unnecessary.

**Reuse, don't duplicate:** when a handoff is a *decision*, it emits a GDR (the
8-section schema) and the evidence record points at it via `gdr_ref`; when it's a
transition log, it's an observability event only (no GDR). Passes the OTAA invariant
(Observable/Traceable/Auditable/Agent-operable).

**Routing:** validation → KB/trust evidence (no backlog); invalidation → AGF
findings-ledger (highest value); improvement → AGF gap backlog. `disposition: routed`
is the AWS→agf-architect handoff point.

**AGF reuse targets** (agf-architect-cited): `~/code/clients/risk/AGF/docs/agentic-observability.md`
(Event Envelope), `.../governance-decision-record.md` (GDR / `gdr_ref`),
`.../shared-vocabulary.md` (OTAA, rings, primitives), `.../findings-ledger.md`
(Q3 promotion home). Spine ledger: `~/code/tools/ai-dev/docs/active/inter-agent-coordination.md`
(`ledger.jsonl` / A2A lifecycle).

### Q2 — Scope (resolved: core-first)

**Core-first** — the discipline ("map or file a gap") applies to the CTO/Krypton/Forge
core first, then expands. The portfolio-map already holds the portfolio-wide snapshot,
so the big picture isn't lost; this avoids low-confidence paperwork across unowned
projects.

### Q3 — Gap-backlog ownership (resolved: AWS emits → agf-architect promotes)

**AWS emits → agf-architect promotes.** AWS agents log evidence into the spine ledger;
agf-architect triages and promotes invalidation+improvement signals in AGF's existing
`findings-ledger.md`. No second backlog.

### Q4 — Portfolio-map promotion (resolved: done)

Done — map is at `aws/docs/active/portfolio-map.md` (owner: Krypton). No action.

### Emission authority (resolved: invalidation is agf-architect-confirmed-only)

Agents may self-tag a *provisional* `signal_type`. **`invalidation` is
agf-architect-confirmed-only** — an agent proposes invalidation; only agf-architect
promotes it in the AGF findings-ledger. Keeps the highest-value signal honest.
