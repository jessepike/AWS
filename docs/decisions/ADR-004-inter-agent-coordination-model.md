---
adr: 004
title: Inter-Agent Coordination Model — Delegation Modes, Handoff Substrate, Coordination Tiers
date: 2026-05-24
status: accepted
owner: Forge
supersedes: []
related: [ADR-003]
---

# ADR-004: Inter-Agent Coordination Model

## Context

AWS now runs a multi-agent team (Krypton at altitude; CTO/Forge and other execs
below; operators at the leaf). As soon as agents dispatch work to each other,
three questions become load-bearing and were previously answered ad hoc:

1. **How does one agent hand work to another?** Spawn a sub-agent, or hand off?
2. **What is the substrate that carries cross-agent messages** without coupling
   agents to each other's private state?
3. **Where does coordination state live** relative to project context and an
   agent's own memory?

A hard platform constraint forces the first answer: in Claude Code, **sub-agents
cannot spawn their own sub-agents**, and they run with inherited/limited context.
A spawned sub-agent is a leaf node. So dispatching real work *down the hierarchy*
cannot be a direct spawn — the target would be unable to delegate further or run
at full capability. This is not a preference; it is a structural property of the
harness.

Three artifacts developed this work and are the rationale of record:
- `tools/ai-dev/docs/active/agent-handoff-protocol.md` — the file-based handoff
  primitive (concept + external review findings folded in).
- `tools/ai-dev/docs/active/inter-agent-coordination.md` — three-tier substrate,
  message-passing principle, and the four cheap additions that graduate an inbox
  to governed coordination.
- `~/.claude/rules/agent-delegation.md` — the active enforcement (auto-loads
  every turn).

The handoff substrate was validated end-to-end this session: the AWS-framing note
was dropped into Krypton's inbox, Krypton consumed it on orient, wrote its own
charter, and moved the note to `inbox/processed/` as a receipt. The CTO state-
pointer handoff (NC remediation framing) also surfaced correctly on CTO orient.

## Decision

**1. Delegation has two modes; the choice is forced, not chosen.**
- **Direct (spawn sub-agent):** synchronous, result returns to caller, target is
  a leaf (cannot delegate, limited context). Use **only for bounded consults**
  that terminate at the target.
- **Indirect (handoff / inbox):** target runs later as its own top-level session —
  full context, full tools, can spawn its own operators. Use for **real work**
  that needs the target at full capability or that the target will itself delegate.
- **Rule:** dispatching work *down the hierarchy* (Krypton → CTO/Forge → operators)
  **MUST be a handoff.** Reserve direct spawning for quick consults.

**2. The handoff substrate is file-based and inbox-only.**
- Sender writes a note to `~/code/_shared/agent-exec/<agent>/inbox/`.
- Receiver scans its inbox on orient, surfaces unread non-expired handoffs, and
  marks them done (moves to `inbox/processed/`) as a receipt.
- Agents **never write to another agent's private state file** (`~/.claude/state/<agent>.md`).
  Publish to the inbox; the receiver decides what to internalize. ("Publish, don't peek.")
- Note schema carries `id` (idempotency), `expires` (14d TTL), `status`
  (unread→read→done), and standard `from/to/priority/type/created/subject`.

**3. Coordination state lives in a distinct third tier.**
- **Tier 1 — project context:** `status.md`, `BACKLOG.md`, `lessons.md`, `CLAUDE.md`.
- **Tier 2 — agent memory:** `~/.claude/state/<agent>.md` (each agent owns its own).
- **Tier 3 — inter-agent coordination plane:** the inbox substrate (and, when
  operationalized, the work-management spine that captures/routes/reports/governs).
  Tier 3 is the new plane this ADR establishes.

**4. Bias-to-action is the operating default within owned domains.**
Captured separately as `~/.claude/rules/bias-to-action.md`: agents propose AND
implement clear improvements within their domain in the same turn; net-new or
cross-domain scope still requires owner green-light (scope-discipline wins ties).

## Consequences

- The delegation rule and bias-to-action rule auto-load into every agent's context
  every turn. They take effect by existing; this ADR records *why*.
- **Cross-model gap:** the no-nesting constraint is Claude-Code-specific. Codex and
  Gemini equivalents need adaptation, not a blind copy — tracked as FORGE-P1-4c
  (cross-model adapters + SessionStart hook read-side + cross-model mirror of the
  delegation rule).
- The inbox↔spine relationship ("one system, two faces" — latent face = the agent,
  deterministic face = the spine) is asserted in `inter-agent-coordination.md` but
  **still requires CTO ratification** (FORGE-P1-4d) before the spine is built on it.
- Rollout of inbox-scan-on-orient beyond the CTO/Krypton/Forge canary to the other
  9 agents is gated and tracked as FORGE-P1-4a.

## Status notes

Accepted for the parts squarely in Forge's domain (delegation modes, handoff
substrate, tiering, bias-to-action). The spine that will sit on Tier 3 is gated on
Foundation work and CTO ratification — this ADR establishes the coordination model
the spine must conform to, not the spine itself.
