---
type: "specification"
description: "Defines status.md — lightweight session state tracking across all stages"
version: "1.3.0"
updated: "2026-02-11"
scope: "adf"
lifecycle: "reference"
location: "adf/ADF-STATUS-SPEC.md"
---

# ADF Status Specification

## Purpose

Define `status.md` — a lightweight document that captures session state for continuity across agent sessions. This is an **environment-layer artifact** that persists across all stages.

---

## Why Status.md

| Problem | Solution |
|---------|----------|
| CLAUDE.md gets polluted with dynamic state | Separate concerns — CLAUDE.md is manifest, status.md is state |
| Agent loses context between sessions | status.md captures where we left off |
| Human cognitive overload managing multiple projects | Quick glance at status.md shows current state |
| Session State embedded in Brief adds noise | Brief stays focused on contract; status is separate |

---

## Relationship to Other Artifacts

| Artifact | Role | Stage Relevance |
|----------|------|-----------------|
| **CLAUDE.md** | Context manifest — points to status.md | All stages |
| **status.md** | Lightweight session state | All stages (environment-layer) |
| **tasks.md** | Task tracking with phase handoff | All stages (minimal in Discover/Design, full in Develop/Deliver) |
| **lessons.md** | Session learnings hot buffer — patterns, gotchas, decisions | All stages (environment-layer) |

**Environment-layer artifact:** Status.md is always present, always loaded, always updated. It tracks session continuity regardless of stage.

**Progression:** In early stages (Discover, Design), status.md is the primary state tracker. In later stages (Develop, Deliver), `tasks.md` handles detailed task management while status.md continues tracking session-level state.

---

## Content Structure

Status.md is intentionally minimal:

```markdown
---
project: "[Project Name]"
stage: "[Discover | Design | Develop | Deliver]"
updated: "YYYY-MM-DD"
---

# Status

## Current State
- **Phase:** [Current phase within stage]
- **Focus:** [What we're working on right now]

## Session Log

| Date | Summary |
|------|---------|
| YYYY-MM-DD | [What was accomplished] |

## Next Steps
- [ ] [Immediate action 1]
- [ ] [Immediate action 2]
- [ ] [Immediate action 3]

## Pending Decisions
- [Decision needed — context if relevant]

## Blockers
- [None or description]

## Notes
[Any context the next session needs that doesn't fit above]
```

**Target size:** 15-30 lines. If it's getting longer, prune or simplify.

---

## lessons.md

**Purpose:** Fast-capture buffer for session learnings. Patterns, gotchas, decision rationale, things that would help the next session or next agent. Written during sessions, promoted to KB on session wrap.

**Relationship to KB:** lessons.md is the local hot buffer. Cross-project patterns get promoted to the Knowledge Base during session-wrap. Project-specific items stay in lessons.md. Promoted items are pruned.

**Relationship to Memory:** lessons.md captures *knowledge* (what we learned). Memory (status.md, Memory MCP) captures *state* (where we are). They're parallel streams, not integrated.

**Content Structure:**

```markdown
# Lessons

## 2026-04-08
- Skill registration requires capabilities-registry deployment, not just SKILL.md creation
- CTO agent at 902 lines was bloated — target 300-400 lines per agent

## 2026-04-03
- Subscription bridge pattern eliminates API costs — use ChatMock for Codex, claude -p for Claude
```

**Rules:**
- One line per lesson. Date-grouped.
- Keep last 15 entries. Prune promoted items on session-wrap.
- If lessons.md exceeds 30 lines, prune oldest entries.
- Cross-project patterns → promote to KB. Project-specific → stays local.

---

## Session History & Pruning

Status.md keeps a rolling history of recent sessions. To prevent unbounded growth:

**Keep:** Last 5 session entries in the Session Log section.

**Prune:** When adding a 6th entry, remove the oldest. Archive to `status-archive.md`.

**Session Log format:**

```markdown
## Session Log

| Date | Summary |
|------|---------|
| 2026-01-27 | Completed review cycle 3, addressed P1 #2 |
| 2026-01-26 | Ran review with GPT-4, logged 4 issues |
| 2026-01-25 | Drafted initial Brief v0.1 |
```

Session Log is the primary session tracking format. Use it from session 1. Keep it concise — one line per session.

---

## Pruning Rules (Mandatory)

Status.md must stay under 30 lines. Pruning is **agent responsibility** at session end.

### What to Prune

| Content | Action | Destination |
|---------|--------|-------------|
| Session log entries beyond 5 | Archive oldest | `status-archive.md` |
| "What's Complete" lists | Archive at stage transition | `status-archive.md` |
| Detailed notes older than 1 week | Archive or delete | `status-archive.md` or delete |
| Decisions | Move to dedicated section | `status-archive.md` or `BACKLOG.md` |

### When to Prune

1. **Every session end:** Check line count. If >30 lines, prune before committing.
2. **Stage transitions:** Archive all "completed" content for the closing stage.
3. **When adf-env audit flags it:** Respond to WARN/FAIL by pruning.

### How to Prune

1. Create `status-archive.md` if it doesn't exist (same directory as status.md)
2. Move content with a date header: `## Archived [DATE]`
3. Keep status.md focused on: current state, next steps, blockers, last 5 sessions
4. Commit both files together

### Archive File Format

```markdown
# Status Archive

Historical session logs and completed work archived from status.md.

---

## Archived 2026-02-04

### What Was Complete
- [x] Item 1
- [x] Item 2

### Session Log (older entries)
| Date | Summary |
|------|---------|
| 2026-01-20 | ... |
```

**Principle:** Status.md is a **window**, not a **ledger**. It shows current state, not full history.

---

## Agent Behavior

### Session Start

1. Agent reads CLAUDE.md (manifest)
2. CLAUDE.md points to status.md
3. Agent reads status.md
4. Agent understands: current phase, last session's work, next steps
5. Agent picks up where previous session left off

### Session End

**Critical:** Agent must close the loop before session ends.

1. Agent updates status.md:
   - Add entry to Session Log with date and what was completed
   - Update "Next Steps" with remaining work
   - Note any new blockers or pending decisions
2. If stage completed, update stage field
3. Commit/save status.md

**Enforcement:** This is a spec requirement. Agents should update status.md before ending work. Human can remind if agent forgets.

---

## CLAUDE.md Integration

CLAUDE.md should reference status.md:

```markdown
## Current Status

See `docs/status.md` for session state.

**Quick glance:**
- Stage: Discover
- Phase: Review Loop
```

The "Quick glance" is optional convenience — agent should still read full status.md.

---

## Context Map Entry

In CLAUDE.md's Context Map:

| File | Load When | Purpose |
|------|-----------|---------|
| docs/status.md | Always | Session state |

Status.md is always loaded — it's small and always relevant.

---

## Stage Transitions

When moving between stages:

1. Update status.md `stage` field
2. Clear completed items from "Next Steps"
3. Add stage-specific next steps
4. Prune Session Log if needed (keep last 5)

### Discover → Design Example

```markdown
## Current State
- **Phase:** Handoff complete
- **Focus:** Beginning Design stage

## Session Log

| Date | Summary |
|------|---------|
| 2026-01-27 | Finalized Brief, passed exit criteria, human sign-off |

## Next Steps
- [ ] Review Brief for Design inputs
- [ ] Identify architecture decisions needed
- [ ] Draft initial tech stack options
```

---

## When to Transition to tasks.md

Status.md is for discrete, sequential work. When work becomes:
- Multi-threaded (parallel tasks)
- Milestone-based (phases with many sub-tasks)
- Complex enough to need prioritization/assignment

...then transition to `tasks.md` (specified separately for Develop stage).

Typical trigger: Entering Develop stage with a non-trivial build.

---

## Format: Markdown vs YAML

**Decision:** Markdown.

Rationale:
- Human-readable without parsing
- Easy to edit manually
- Consistent with other ADF artifacts
- YAML would be overkill for ~20 lines of state

---

## File Location

```
/project-root/
  docs/
    intent.md
    discover-brief.md
    status.md          # <-- Session state
  CLAUDE.md
  README.md
```

No stage prefix needed — there's only one status.md per project.

---

## Validation Criteria

A well-formed status.md:

- [ ] Has current stage and phase
- [ ] Has Session Log table with date and summary
- [ ] Has actionable "Next Steps" (not vague)
- [ ] Under 30 lines
- [ ] Updated at end of each session

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-26 | Initial spec |
| 1.1.0 | 2026-01-27 | Added session log format, pruning guidance |
| 1.2.0 | 2026-02-04 | Added explicit "Pruning Rules (Mandatory)" section — defines what/when/how to prune, agent responsibility, archive file format |
| 1.3.0 | 2026-02-11 | Session Log table is now the primary format from session 1. Removed "Last Session" single-entry format. Aligns spec with actual practice across all ADF projects. |

---

## References

- ADF-PROJECT-CLAUDE-MD-SPEC.md (CLAUDE.md references status.md)
- ADF-DISCOVER-SPEC.md (Discover phase tracking)
- ADF-TAXONOMY.md (Status definitions)
