---
status: active
updated: 2026-05-24
---

# Intent: Agentic Work System

## North Star

> Build and operate a personal agentic work system — the governed substrate, operating methodology, and agent org that lets me orchestrate a portfolio of work at high leverage and low cognitive load. Built deliberately AGF-aligned as an act of dogfooding, so that operating it both (a) compounds my capability and is monetizable through consulting and products, and (b) validates and sharpens AGF itself.

This is the gravity well. Every active workstream should trace back to it. `orient` re-grounds against this statement each session and flags work that doesn't trace; the AWS `CLAUDE.md` routes here as the canonical re-grounding source (resolver discipline — see ADR-006).

## Living North Star (method)

The North Star is kept honest by separating two layers and logging the signals that move it:

- **INVARIANT (the why — rarely changes):** learn → leverage → monetize, while improving AGF. This is the durable purpose. If this changes, the project has fundamentally changed.
- **ARTICULATION (the statement above — versioned):** the current best phrasing of the North Star. It is expected to be re-sharpened as understanding improves. Version it; don't silently overwrite it.

### Signal log

Dated entries that materially shaped the articulation or the frame. Newest first.

- **2026-05-24** — Established four-layer model (substrate / operating-system / org / output) as the organizing frame; AWS = the whole enterprise, "personal AI infrastructure" = its substrate layer (nested, not parallel). AGF + Krypton named as the cross-cutting alignment pair (plumb line + continuity role).

## Problem

The major components of the agentic work system — ADF, Knowledge Base, Memory, Capabilities Registry, Krypton, Link Triage, and Work Management — exist independently but lack a governing project to track system-level integration, health, and evolution. Each component has its own project workspace, but there's no meta-level coordination to ensure they work together as a coherent system.

## Desired Outcome

A coherent system where:
- Components are properly linked with defined communication protocols
- The rings (Governance, Intelligence, Knowledge, Control, Observability) operate at each layer
- Autonomy can scale as trust builds at each layer
- System health is observable across all components
- Integration gaps are identified and tracked
- Evolution is deliberate, not accidental

## Why This Matters

Without system-level governance, drift accumulates silently. Components evolve independently, interfaces degrade, and the architecture diagram becomes aspirational rather than descriptive. This project is the connective tissue that keeps the system honest.

## Success Looks Like

- Any agent session can orient itself within the system by reading this project's artifacts
- Component integration gaps are tracked and prioritized in the backlog
- System health is assessable without visiting every sub-project individually
- The architecture doc stays current with reality
- Ring instantiation is formalized and measurable

## Non-Goals

- This project does not build software — it governs the system
- This project does not replace component-level project management
- This project does not own any component's backlog
