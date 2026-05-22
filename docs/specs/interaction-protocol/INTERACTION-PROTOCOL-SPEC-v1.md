---
spec: interaction-protocol
version: 1.1.0
updated: 2026-05-22
owner: forge
adr: ADR-003
status: draft
---

# Interaction Protocol Spec v1

**The contract between AWS agents and the operator for rich human-in-the-loop
interaction.** Defines the interaction classes, the request envelope, the
structured return contract, the surface-selection rule, and the fallback.
Created by ADR-003. This is the canonical home for the contract — agent
definitions and the Canvas server point here, never copy it.

---

## 1. Model

```
Agent needs structured input
        │
        ├─ small / synchronous / yes-no ──────────────► AskUserQuestion (terminal)
        │
        └─ rich interaction class ─► dispatch to Canvas ─► operator reviews/edits/decides
                                          │                         │
                                   (agent releases)         (structured response)
                                          │                         │
                                          └──── re-invoked by spine ─┘
                                                         │
                                  Canvas unreachable? ──► AskUserQuestion fallback
```

Two surfaces, **one request schema**. The terminal path is always available;
Canvas is the richer renderer for the four interaction classes below.

## 2. Interaction classes

| Class | Use for | Operator can | Returns |
|---|---|---|---|
| `decision-set` | N questions, each pick-one or pick-many | Select options, add per-question notes | `responses[]` |
| `document-review` | Read a document, comment, edit | Inline comments + direct edits | `comments[]` + `edits[]` (diff) |
| `approval-gate` | Approve / reject a specific proposed action | Approve, reject, or request-changes + reason | `decision` + `reason` |
| `visual-artifact` | View + annotate a diagram/mockup (the genuinely-custom case). Source is **either** a file path (`artifact_path`) **or** inline HTML (`artifact_inline`) — see §3 | Annotate, comment | `comments[]` |

Anything that doesn't fit a class stays in the terminal. Do not invent ad-hoc
classes; propose additions via ADR.

## 3. Request envelope

The request reuses the `AskUserQuestion` shape so the same payload renders in
either surface. Canvas-specific fields are additive and optional.

```jsonc
{
  "interaction_id": "uuid",          // correlates request ↔ response
  "class": "decision-set",           // decision-set | document-review | approval-gate | visual-artifact
  "title": "Handoff schema — open decisions",
  "artifact_path": "/abs/path/to/artifact",   // optional: absolute path to doc/HTML to render
  "artifact_inline": null,           // optional: inline HTML string (visual-artifact only); mutually exclusive with artifact_path
  "questions": [                     // AskUserQuestion-shaped; used by decision-set
    {
      "question_id": "log_location",
      "question": "Where should the log live?",
      "header": "Log location",
      "multiSelect": false,
      "options": [
        { "key": "central",     "label": "One central file", "description": "...", "recommended": true },
        { "key": "per_project", "label": "One per project",  "description": "..." }
      ]
    }
  ],
  "fallback": "ask-user-question",   // what the agent does if Canvas is unreachable
  "trace_id": "uuid"                 // links to the handoff-event boundary record
}
```

- `question_id` / `key` are **stable machine identifiers** — the agent keys off
  these, never off display labels.
- `recommended: true` marks a default option (rendered as a badge). It is a
  hint, never a pre-selection.
- **Artifact source (all classes that render a document/visual):** use
  `artifact_path` (an **absolute** path to a `.md` / `.html` file Canvas reads
  from disk) **or** `artifact_inline` (an HTML string the request carries
  directly). They are **mutually exclusive** — set exactly one. `artifact_inline`
  is valid only for `visual-artifact` (the genuinely-custom case); `document-review`
  always uses `artifact_path`. Inline HTML renders in the sandboxed iframe with
  scripts disabled, same as a file (see ADR-003 / §9 — arbitrary script-bearing
  HTML is not a first-class path).

## 4. Return contract (normative)

The response is **structured data**, not prose. One shape per class; common
envelope fields are shared.

```jsonc
{
  "interaction_id": "uuid",          // MUST match the request
  "class": "decision-set",           // echoes the request class — see rule 5
  "artifact_path": "/abs/path/...",  // echoes the request (null if artifact_inline was used)
  "status": "submitted",             // submitted | draft | dismissed
  "submitted_at": "2026-05-22T18:30:00Z",   // ISO-8601 UTC (trailing Z) — see rule 6

  // decision-set
  "responses": [
    { "question_id": "log_location", "selected": ["central"], "note": "revisit if noisy" }
  ],

  // document-review
  "comments": [
    { "anchor": "section:storage", "body": "make this dual-write", "ts": "2026-05-22T18:29:00Z" }
  ],
  "edits": [
    { "kind": "diff", "unified_diff": "--- a\n+++ b\n@@ ..." }
  ],

  // approval-gate
  "decision": "request-changes",     // approve | reject | request-changes
  "reason": "tighten the high_stakes rule first"
}
```

Rules:
1. `selected` is always an **array** (one element for single-select). Values are
   option `key`s, never labels.
2. Unanswered questions are **omitted**, not sent with a null/placeholder. The
   agent treats absent as undecided.
3. `status: "draft"` means partial — the agent may prompt to continue rather
   than act. `status: "dismissed"` means the operator declined — fall back or ask.
4. The agent **must** validate `interaction_id` matches its outstanding request
   before acting on a response. This is the **canonical** `interaction_id` —
   when a response arrives via the Canvas transport (§5), the wrapper-level
   `interaction_id` MUST equal this `payload.interaction_id`; the agent validates
   against the payload copy.
5. `class` **echoes** the request's `class` verbatim. Consumers dispatch on it
   directly rather than inferring the shape from which fields are present.
6. **All timestamps are ISO-8601 UTC with a trailing `Z`** (e.g.
   `2026-05-22T18:30:00Z`). This applies to `submitted_at` (the canonical stored
   response timestamp) and every `ts` field (comments, transport wrapper). Epoch
   integers are not used anywhere in the protocol.

## 5. Transport (Canvas MCP)

The Canvas MCP server delivers responses through its read tools. **All
list-returning tools wrap their array in a record** to satisfy the
`structuredContent` schema:

```jsonc
// get_user_messages  →  one messages[] element per response:
{
  "messages": [
    {
      "interaction_id": "uuid",     // CANONICAL routing copy; MUST equal payload.interaction_id
      "ts": "2026-05-22T18:30:00Z", // ISO-8601 UTC; echoes payload.submitted_at
      "payload": { /* the verbatim §4 return object, incl. its own interaction_id, class, status */ }
    }
  ]
}

// get_comments  →
{ "comments": [ { "anchor": "...", "body": "...", "ts": "2026-05-22T18:29:00Z" } ] }
```

**Wrapper vs payload (normative):** the wrapper-level `interaction_id` is the
**transport/routing** field the spine uses to match the response to an
outstanding request. The `payload` is the **complete, self-contained §4 operator
response** and intentionally repeats `interaction_id` (and `class`, `status`,
`submitted_at`). The duplication is deliberate — the payload must stand alone if
extracted from the envelope. The two `interaction_id` values **MUST be equal**;
the agent validates against `payload.interaction_id` (§4 rule 4). The wrapper
`ts` mirrors `payload.submitted_at`; if they ever differ, `payload.submitted_at`
wins. Canvas MUST NOT add fields to `payload` beyond the §4 contract.

> **Known defect (2026-05-22):** `get_user_messages` and `get_comments`
> currently return a bare array and error with `expected record, received
> array`. The fix is to wrap as above. Until fixed, the only working return
> path is manual copy-paste into the terminal — acceptable for dogfood, not for
> the protocol. This is the build-agent contract item.

The agent dispatches a request, releases (does not block the terminal), and is
re-invoked by the wm-agent spine when a matching `interaction_id` response
arrives. Polling is a fallback for environments without spine wake-ups.

### 5.1 Lifecycle events (Canvas-emitted)

Canvas emits a lifecycle event at each state transition of an interaction. These
are **Canvas's observability surface** — the spine consumes them to drive
re-invocation and to write handoff-event records (§7). Canvas does **not** write
the handoff-event log itself.

| Event | Emitted when | Carries |
|---|---|---|
| `interaction.dispatched` | Request received and rendered | `interaction_id`, `class`, `trace_id`, `ts` |
| `interaction.read` | Operator opens / views it | `interaction_id`, `trace_id`, `ts` |
| `interaction.responded` | Operator submits (`status: submitted` or `draft`) | `interaction_id`, `trace_id`, `status`, `ts` |
| `interaction.dismissed` | Operator declines (`status: dismissed`) | `interaction_id`, `trace_id`, `ts` |

Every lifecycle event carries the `trace_id` from the request envelope unchanged.
All `ts` values are ISO-8601 UTC (§4 rule 6).

## 6. Surface-selection rule

Reach for **Canvas** when the interaction is one of the four classes AND is
worth a context switch (multi-decision, document review, risky approval, visual
annotation). Stay in the **terminal** for single yes/no, quick clarification,
or fast synchronous back-and-forth. **Always** fall back to `AskUserQuestion`
when Canvas is unreachable or the operator signals they're heads-down in the
terminal. Canvas is never a hard dependency (ADR-003).

## 7. Tie-in to handoff-event schema

Each dispatched interaction corresponds to a handoff-event boundary record with
`human_in_loop: true`, `gate_type` = `question` (decision-set / document-review)
or `review` (approval-gate), and the shared `trace_id`. This gives
observability into protocol usage and success rate, and is the dogfooding
evidence AGF wants. See `pike-agents/docs/handoff-event-schema.md`.

### Ownership boundary (normative)

The handoff-event log is written by the **wm-agent spine**, not by Canvas and
not by the dispatching agent. This matches the handoff-event schema's capture
model — records are written automatically by the system (e.g. on `SubagentStop`
/ spine transitions), never authored by an agent or the renderer. Concretely:

| Responsibility | Owner |
|---|---|
| Generate `trace_id` and put it in the request envelope | **Dispatching agent** |
| Render the interaction; carry `trace_id` unchanged through to the response | **Canvas** |
| Emit `interaction.dispatched/read/responded/dismissed` lifecycle events (§5.1) | **Canvas** |
| Consume lifecycle events; write the handoff-event boundary record (`human_in_loop`, `gate_type`, `trace_id`, cost/outcome) | **wm-agent spine** |
| Re-invoke the dispatching agent on a matching response | **wm-agent spine** |

**Canvas's boundary, stated plainly:** Canvas is responsible only for (a)
echoing `trace_id` from request to response untouched and (b) emitting the §5.1
lifecycle events. Canvas does **not** write, read, or own the handoff-event
JSONL log. Filling the boundary record's cost/outcome/`gate_type` fields and
appending the line is entirely the spine's job.

## 8. Versioning

Semver. New interaction classes or return-shape changes bump minor; breaking
envelope changes bump major and require an ADR. v1 scope is the four classes
above; drift detection, quality scoring of interactions, and a full generative-
UI component library are explicitly out of v1 scope.

## 9. Out of scope for v1

- Arbitrary agent-authored HTML as a first-class path (use `visual-artifact`
  for the custom case; otherwise use a typed class).
- Real-time collaborative editing.
- Auth / multi-operator routing (single operator assumed).
- Offline queueing of responses beyond what the spine provides.

## 10. Changelog

- **v1.1.0 (2026-05-22)** — Resolved three wire-shape ambiguities for the
  AgentCanvas conformance build (additive, minor bump per §8):
  - **`interaction_id` canonical location:** wrapper-level is the transport/routing
    copy; `payload` keeps its own (self-contained §4 response); the two MUST be
    equal; agent validates against `payload.interaction_id` (§4 rule 4, §5).
  - **Time format:** ISO-8601 UTC (trailing `Z`) everywhere — `submitted_at` is
    the canonical stored timestamp; transport/comment `ts` are ISO-8601 too;
    epoch integers removed from all examples (§4 rule 6, §5).
  - **Handoff-event ownership:** the wm-agent spine writes the boundary record;
    Canvas only echoes `trace_id` and emits §5.1 lifecycle events (§7).
  - Added `class` echo to the §4 response. Added §5.1 lifecycle events. Clarified
    `visual-artifact` source as `artifact_path` XOR `artifact_inline` (§2, §3).
- **v1.0.0 (2026-05-22)** — Initial spec from ADR-003. Four interaction classes,
  shared request envelope, structured return contract, transport, fallback.
