---
type: "specification"
description: "Defines BACKLOG.md and active task tracking — work intake through completion with handoff"
version: "1.0.0"
updated: "2026-03-23"
scope: "adf"
lifecycle: "active"
supersedes: "ADF-BACKLOG-SPEC v1.1.0, ADF-TASKS-SPEC v1.0.0"
---

# ADF Task Lifecycle Specification

## Summary

One spec for the full work lifecycle: intake → prioritization → execution → completion. Two artifacts, two layers, one flow.

- **BACKLOG.md** (root artifact) — project-layer work queue. What needs to happen.
- **Active task tracking** (agent-internal) — execution-layer. How an agent is doing the current item right now.

These are different layers. Don't conflate them.

---

## Two Layers of Task Tracking

| Layer | Artifact | Who Writes | Scope | Persistence |
|-------|----------|------------|-------|-------------|
| **Project** | `BACKLOG.md` | Human + Agent | All work items across the project | Permanent (committed) |
| **Execution** | Agent-internal (Claude TodoWrite, Codex task lists) | Agent | Current session's work breakdown | Ephemeral (session-scoped) |

**Project layer** is canonical truth. If it's not in `BACKLOG.md`, it's not tracked.

**Execution layer** is the agent's internal decomposition of a backlog item into implementable steps. It lives and dies within the session. Agents manage their own internal todos however their runtime supports — Claude uses TodoWrite, Codex uses its built-in task system. These are implementation details, not project artifacts.

---

## BACKLOG.md

### Purpose

Single place to capture, triage, and sequence work. Answers one question fast: **what should we work on next?**

Lives at project root. Always visible. Part of the root artifact set.

### Structure

```markdown
---
type: "tracking"
project: "[Project Name]"
updated: "YYYY-MM-DD"
---

# Backlog

## Queue

| ID | Item | Type | Pri | Size | Status | Why |
|----|------|------|-----|------|--------|-----|
| B12 | Add rate limiting to API | Enhancement | P1 | M | pending | Production traffic spikes causing 503s |
| B13 | Update deployment docs | Maintenance | P2 | S | pending | New deploy process not documented |

## Archive

| ID | Item | Completed | Realized? |
|----|------|-----------|-----------|
| B11 | Fix auth token expiry | 2026-03-20 | Yes — 503 errors eliminated |
| B10 | Scaffold test harness | 2026-03-18 | Yes — CI pipeline now runs |
```

### Queue Columns

| Column | Required | Description |
|--------|----------|-------------|
| ID | Yes | `B1`, `B2`, ... Monotonically increasing. Never reused. |
| Item | Yes | Brief description of the work |
| Type | Yes | Bug fix, Enhancement, Maintenance, Architecture, Setup, Script |
| Pri | Yes | `P1` (blocking), `P2` (important), `P3` (future/nice-to-have) |
| Size | Yes | `S` (single session), `M` (1-2 sessions), `L` (needs planning phase) |
| Status | Yes | `pending`, `in_progress`, `blocked` |
| Why | Yes | What friction this removes or decision it enables. One sentence. |

### Archive Columns

| Column | Required | Description |
|--------|----------|-------------|
| ID | Yes | Original ID from queue |
| Item | Yes | Brief description |
| Completed | Yes | Date (YYYY-MM-DD) |
| Realized? | Yes | Did it deliver the stated Why? One sentence. "Partial" if incomplete. |

### Maintenance Rules

1. **Adding:** Append with next available ID. Default status: `pending`. Must have Why.
2. **Completing:** Remove from Queue, add to Archive with date and Realized? outcome.
3. **Reprioritizing:** Change Pri, re-sort (P1 → P2 → P3, then by ID within priority).
4. **Triage:** Review periodically. Reprioritize, remove stale items, split L items.
5. **ID stability:** IDs are permanent. Never reuse or renumber. Gaps are fine.

### Quick-Check Protocol

1. Open `BACKLOG.md`
2. Read Queue top to bottom
3. First `pending` item at highest priority is next
4. If top item is `blocked`, skip to next `pending`

---

## Graduation: Backlog → Execution

When an agent picks up a backlog item:

1. Change backlog item status to `in_progress`
2. Decompose into execution-layer tasks using agent's native task system
3. Execute tasks
4. When complete: move backlog item to Archive with Realized? outcome

The agent's internal task breakdown does NOT get written back to BACKLOG.md. Backlog tracks *what* at the project level. Agent internals track *how* at the session level.

### Handoff Between Sessions

If work on a backlog item spans multiple sessions, context carries forward via:

- **status.md** — current state, what was done, what's next
- **Committed work** — code, docs, artifacts in the repo
- **BACKLOG.md** — item stays `in_progress` with the same Why

Agents pick up where the previous session left off by reading status.md and the in_progress backlog item. They rebuild their own execution-layer task breakdown from there.

### Handoff Block (Optional)

For complex multi-phase work, status.md can include a handoff block:

```markdown
## Handoff

| Field | Value |
|-------|-------|
| Backlog Item | B12: Add rate limiting to API |
| Phase | Phase 1 complete (middleware scaffolded) |
| Next | Phase 2: configure per-route limits |
| Blocker | None |

**Done this phase:**
- Scaffolded rate limiting middleware
- Added Redis connection for distributed counting

**Next phase requires:**
- Route config schema design
- Integration tests for rate limit responses

**Build notes:**
- Used sliding window algorithm — token bucket was overkill for our scale
```

Rules:
- Overwrite, don't append. Each phase boundary replaces the previous handoff.
- Keep it short. 10-20 lines max. Orientation, not journal.
- Phase field uses descriptive name, not just a number.

---

## Stage-Specific Behavior

### Early Stages (Discover/Design)

Backlog items are simple. Agent execution-layer tracking is lightweight. Examples:
- "Research competitor X"
- "Draft product brief"
- "Identify architecture options"

No complex dependencies or handoff blocks needed.

### Execution Stages (Develop/Deliver)

Backlog items are larger (M/L sized). Agent execution-layer tracking is detailed with acceptance criteria, dependencies, testing. Handoff blocks in status.md become important for multi-session work.

### Operate Stage

Backlog receives new items from production feedback, incidents, and monitoring. Items flow back through the lifecycle.

---

## Task Granularity (Execution Layer)

Guidance for agents decomposing backlog items into execution tasks:

- One agent, one session completion
- Clear, verifiable acceptance criteria
- Defined testing approach
- Can be marked complete with confidence

**Too large:** "Build the authentication system"
**Right size:** "Implement login endpoint with JWT validation"
**Too small:** "Add semicolon to line 42"
**Right size:** "Fix linting errors in auth module"

---

## Relationship to Other Artifacts

| Artifact | Relationship |
|----------|-------------|
| `status.md` | Tracks current session state + optional handoff block. Complements backlog. |
| `intent.md` | North Star. Backlog items should trace back to intent. |
| `decisions.md` | Decisions may generate backlog items. Backlog items may generate decisions. |
| `CLAUDE.md` | Points agents to BACKLOG.md for work orientation. |

---

## What This Spec Does NOT Cover

- **Agent-internal task management:** How Claude, Codex, or Gemini manage their own task lists is a runtime concern, not an ADF concern. ADF only cares about BACKLOG.md and status.md.
- **Plan.md / implementation plans:** These live in `docs/active/` per the folder structure spec. They're working documents that inform execution, not task tracking artifacts.
- **Sprint/iteration planning:** ADF is stage-based, not sprint-based. Backlog priority is the sequencing mechanism.
