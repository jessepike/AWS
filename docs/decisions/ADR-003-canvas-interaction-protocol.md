---
adr: 003
title: Canvas Interaction Protocol for Rich Human-in-the-Loop Handoffs
date: 2026-05-22
status: accepted
owner: Forge
supersedes: []
related: [ADR-001, ADR-002]
---

# ADR-003: Canvas Interaction Protocol for Rich Human-in-the-Loop Handoffs

## Context

The terminal is excellent for fast, linear, low-stakes exchange and poor at
structured interaction. When an agent needs the operator to make a set of
decisions, review and edit a document, or approve a risky action, the terminal
forces that into either a wall of prose or a sequence of one-at-a-time
questions. Both are lossy and slow.

Agent Canvas (an external app, build in progress) renders agent-produced
artifacts in rich HTML — decision forms, reviewable documents, approval gates,
visual artifacts — and is intended to send a structured response back to the
terminal agent. A 2026-05-22 dogfood of the workflow (the handoff-event-schema
v0.2 → v0.3 round-trip) validated the *direction* and surfaced two facts:

1. **Rendering is the easy part.** A hand-rolled HTML decision form rendered
   and behaved correctly in the canvas (JS executes; selections update live).
2. **The structured round-trip is the actual product, and it was missing.**
   The only working return path was the operator copying a text payload and
   pasting it into chat, which the agent then parsed from prose. The canvas's
   native send-back tools (`get_user_messages`, `get_comments`) errored with a
   schema mismatch (`expected record, received array`) and could not deliver
   structured input at all.

The community is converging here (Claude Artifacts, ChatGPT Canvas, MCP-UI, the
MCP elicitation spec addition). The risk is over-rotating: making "rich HTML"
the medium-by-default, hand-authored per artifact, with free-text returns. That
does not scale and is brittle.

This decision establishes how AWS agents interact with the operator when they
need richer-than-text input — as a **typed contract**, not an emergent habit.

## Decision

**AWS agents use a typed interaction protocol for rich human-in-the-loop
handoffs. The protocol — not any specific medium — is the default. Agent Canvas
is the preferred renderer for the rich interaction classes; the terminal
(`AskUserQuestion`) is the always-available fallback.**

Five points define the decision:

1. **Typed interaction classes, not raw HTML.** Agents declare *what kind of
   interaction they need* — `decision-set`, `document-review`, `approval-gate`,
   or `visual-artifact` — and pass structured data. The renderer (Canvas)
   produces the right widget. Agents do not hand-author bespoke HTML per
   artifact. (Full class list and schemas: the Interaction Protocol Spec.)

2. **Reuse the `AskUserQuestion` envelope as the request shape.** The existing
   structured question/option/preview contract is the request envelope. Canvas
   becomes a rich *renderer* for that contract, not a parallel protocol. This
   keeps the terminal fallback and the canvas path on one schema.

3. **The return is structured and machine-actionable, never free text.** The
   response carries `interaction_id`, per-question `selected` keys + optional
   notes, document edits as a diff, and comments — as data the agent acts on
   deterministically. Free-text-only returns are disallowed.

4. **Canvas is optional with terminal fallback — not a hard dependency.** If
   Canvas is unavailable, or the interaction is small/synchronous, the agent
   degrades to `AskUserQuestion` in-terminal. No agent hard-blocks on the
   external app.

5. **A canvas interaction is a governance boundary event.** It maps to the
   handoff-event schema with `human_in_loop: true` and
   `gate_type: question | review`, and its async lifecycle (dispatch → release →
   re-invoke on response) is owned by the wm-agent spine. The interaction
   protocol is the human-facing half of the same telemetry/spine work, not a
   side quest.

### Rollout scope

- **Orchestrators first.** Krypton and the exec agents (CTO, CFO, CPO, CRO,
  CISO, CMO) — the agents that produce review-worthy artifacts — adopt the
  protocol first. Prove it there, then extend to all agents and subagents in a
  follow-up (requires its own green-light; not authorized by this ADR).
- This ADR authorizes the **spec and the contract**, not the agent-definition /
  CLAUDE.md wiring. That rollout is a separate, approved step.

### When to reach for Canvas vs terminal

| Situation | Surface |
|---|---|
| Multi-question decision set | Canvas `decision-set` |
| Document review with inline comment / edit | Canvas `document-review` |
| Approve / reject / request-changes on a risky action | Canvas `approval-gate` |
| Diagram / mockup to view + annotate | Canvas `visual-artifact` |
| Single yes/no, quick clarification, synchronous back-and-forth | Terminal `AskUserQuestion` |
| Canvas unreachable, or operator heads-down in terminal | Terminal fallback (always) |

## Consequences

**Positive:**
- Returns are data, not prose — agents act deterministically, no parsing of
  free text.
- One schema (`AskUserQuestion` envelope) spans both surfaces; the fallback is
  free.
- Bespoke per-artifact HTML is eliminated; agents fill typed classes.
- Cleanly ties human-in-the-loop interaction into the handoff-event /
  spine telemetry already being built.

**Negative / risks:**
- Requires the Canvas server to honor the contract (structured return +
  fixed response shapes). Tracked as the build-agent contract.
- A typed-class system is less flexible than arbitrary HTML for one-off rich
  artifacts. Mitigated by the `visual-artifact` class accepting a rendered
  payload for the genuinely-custom case.
- Context-switch cost to an external app. Mitigated by the decision rule above
  — terminal stays default for small/synchronous exchanges.

## Enforcement

Soft-rule today. Once the protocol spec is stable and Canvas honors the
contract, orchestrator agent definitions reference the spec (follow-up step).
The handoff-event schema captures each canvas interaction as a boundary event,
giving observability into how often the protocol is used and whether it
succeeds.

## Related decisions

- **ADR-001:** AWS governance activation (Forge as write authority).
- **ADR-002:** Canonical doc homes (this ADR's spec is the canonical home for
  the interaction contract; agent definitions point to it, never copy it).

## References

- `~/code/_shared/aws/docs/specs/interaction-protocol/INTERACTION-PROTOCOL-SPEC-v1.md` — the protocol detail + normative contract. Spec **v1.1.0** (2026-05-22) hardened the wire shape for the AgentCanvas conformance build: canonical `interaction_id` location (wrapper = transport, payload = self-contained), ISO-8601 UTC timestamps everywhere, and an explicit handoff-event ownership boundary (spine writes the record; Canvas echoes `trace_id` + emits lifecycle events). Consistent with decision point 5 — the spine owns the async lifecycle and telemetry; Canvas is the renderer.
- `~/code/_shared/pike-agents/docs/handoff-event-schema.md` — boundary-event schema a canvas interaction maps to
- 2026-05-22 dogfood: handoff-event-schema v0.2 → v0.3 canvas round-trip (forcing function; surfaced the `get_user_messages` array-vs-record bug)
