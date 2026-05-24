---
adr: 006
title: North Star Capture and Resolver
date: 2026-05-24
status: accepted
owner: Forge
ratifiers: [Krypton, Jesse]
supersedes: []
related: [ADR-002, ADR-004, ADR-005]
---

# ADR-006: North Star Capture and Resolver

## Context

AWS had an `intent.md` that stated a problem and desired outcome, but it had quietly
drifted into stale, component-level framing — and nothing pointed back to it. It was
**content with no resolver**: a document no harness re-grounded against, so sessions
oriented off `status.md` / `BACKLOG.md` and the stated intent slowly diverged from how
the system was actually being built and described. Drift was silent because nothing was
responsible for catching it.

This session two things crystallized that make a durable North Star worth capturing now:

1. **A clear enterprise frame emerged.** AWS is best understood as a **four-layer
   enterprise model**:
   - **Substrate** — the governed infrastructure ("personal AI infrastructure" sits
     here, as the substrate layer, nested *inside* AWS — not a parallel thing).
   - **Operating system** — the methodology / how work is run (ADF, session lifecycle,
     standards).
   - **Org** — the agent organization (Forge, Krypton, the domain agents).
   - **Output** — the leverage produced: capability compounding, plus monetizable
     consulting and products.
   AWS = the whole enterprise across all four layers. This frame is the organizing
   lens for the North Star statement.

2. **The AGF + Krypton cross-cutting alignment pair was named.** AGF is the plumb line
   (the governance framework AWS dogfoods and validates — ADR-005), and Krypton is the
   continuity role (the chief-of-staff that holds coherence across sessions and agents
   — ADR-004). Together they are the cross-cutting pair that keeps the four layers
   aligned to the why.

## Decision

**Capture the agentic-work-system North Star in `docs/intent.md` as the canonical
gravity well, and wire a resolver so it stays the gravity well rather than drifting
into unreferenced content.**

The resolver has two parts, following the harness/resolver discipline (a lean
`CLAUDE.md` of pointers, not content; a resolver that routes intent → document):

1. **CLAUDE.md pointer** — the governing AWS `CLAUDE.md` carries a one-line pointer to
   `docs/intent.md` as the North Star / re-grounding source. Pointer, not content,
   keeping `CLAUDE.md` lean (consistent with the canonical-doc-homes discipline of
   ADR-002).
2. **orient re-grounding step** — the `orient` session skill reads `intent.md`'s North
   Star and performs a **trace-check**: every active workstream must trace back to the
   North Star, and any that does not is flagged in the situation report. This is the
   enforcement mechanism — drift surfaces every session, before it accumulates.

The North Star itself is structured as a **Living North Star**: an INVARIANT (the why —
learn → leverage → monetize, while improving AGF — rarely changes) separated from a
versioned ARTICULATION (the current best phrasing), with a dated SIGNAL LOG recording
what moved the frame.

## Rationale

- **The four-layer model gives the North Star a stable frame.** Capturing it without a
  frame would have produced another phrasing that drifts; anchoring it to
  substrate / operating-system / org / output gives every layer a place to trace to.
- **The prior intent.md drifted because it was content with no resolver.** A document
  that nothing re-grounds against cannot hold. The fix is not "write a better
  document" — it is to wire a resolver: keep CLAUDE.md a lean set of pointers, and
  route intent → document via a pointer plus an active re-grounding step in orient.
  Capture + resolver together; capture alone repeats the failure.
- **AGF + Krypton are the cross-cutting alignment pair.** AGF (plumb line, ADR-005) and
  Krypton (continuity, ADR-004) are what keep the layers aligned to the invariant why.
  The North Star names them so the alignment relationship is explicit, not implicit.
- **Traceability serves AGF alignment.** The trace-check is itself a dogfooding act:
  requiring every workstream to trace to a governed North Star is governance-in-the-loop,
  and the friction (or lack of it) is AGF evidence. Drift caught early is an alignment
  signal; "this work doesn't trace" is either a scope error or a North Star that needs
  re-articulation — both are useful AGF feedback.

## Consequences

- `docs/intent.md` now leads with the North Star and the Living North Star method;
  the prior problem/outcome/success structure is preserved beneath it.
- `orient` gains a trace-check step and a report line; because the skill is deployed via
  the capabilities-registry, the source edit must be re-deployed for the change to take
  effect in sessions. Tracked as a Forge follow-up.
- Future North Star re-articulations append to the signal log and bump the articulation
  version rather than overwriting silently. The invariant is expected to hold.
- Risk to manage: trace-check theater (rubber-stamping "all traces"). Mitigation — the
  flag must name a specific untraceable item or affirm none; an empty affirmation with
  visible drift is a process failure to correct, not a pass.
