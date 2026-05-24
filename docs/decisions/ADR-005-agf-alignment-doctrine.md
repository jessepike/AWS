---
adr: 005
title: AGF Alignment — AWS as a Dogfooding Reference Implementation
date: 2026-05-24
status: proposed
owner: Forge
ratifiers: [Krypton, Jesse, agf-architect]
supersedes: []
related: [ADR-001, ADR-004]
---

# ADR-005: AGF Alignment — AWS as a Dogfooding Reference Implementation

> **Status: PROPOSED.** Forge drafts this per Krypton's charter; ratification is
> owned jointly by Krypton, Jesse, and agf-architect. Do not treat as accepted
> until the three have signed off. This is FORGE-P0-2.

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

## Decision (proposed)

**AWS adopts AGF alignment as a first-class goal: AWS becomes a dogfooding
reference implementation of AGF, in order to validate, invalidate, and improve
AGF.** This reverses the inspiration-only doctrine in `overview.md`.

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
  double as AGF evidence.

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

## Open ratification questions (for Krypton / Jesse / agf-architect)

1. What is the minimum AGF evidence schema for v1 — what makes a finding count?
2. Does "every component maps or files a gap" apply to all of AWS now, or to the
   CTO/Krypton/Forge core first, then expand?
3. Who owns the AGF gap backlog — agf-architect in the AGF repo, or a shared lane?
4. Promotion timing for the portfolio map from `agf-applied/` to `aws/docs/active/`.
