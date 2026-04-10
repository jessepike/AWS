---
type: "transition-prompt"
description: "Guidance for transitioning from Design to Develop stage"
from_stage: "design"
to_stage: "develop"
version: "1.0.0"
updated: "2026-02-03"
---

# Design → Develop Transition

## Prerequisites

Before transitioning from Design to Develop, verify:

- [ ] `design.md` exists with approach decisions documented
- [ ] `BACKLOG.md` exists with prioritized work items
- [ ] Development environment ready (tools, dependencies identified)
- [ ] All design work committed
- [ ] No critical or high issues open from review

---

## Artifact Cleanup Checklist

### Deliverables (Keep Active)
These artifacts carry forward to Develop:
- `intent.md` — North Star reference
- `brief.md` — Scope and criteria
- `design.md` — Approach and architecture
- `BACKLOG.md` — Work items
- Decision records (if in `docs/decisions/`)
- `status.md` — Updated with handoff

### Working Artifacts (Archive)
Move these to `_archive/` with naming `_archive/YYYY-MM-DD-<name>.md`:
- Draft design documents
- Architecture exploration notes
- Spike reports
- Prototype analysis
- Alternative approach evaluations

**Action:** Execute cleanup before updating status.md

---

## Status Update Requirements

Update `status.md` with:

1. **What was produced**
   - Summary of design.md and BACKLOG.md
   - Key decisions made
   - Architecture overview

2. **What was archived**
   - List of archived artifacts
   - Rationale for each

3. **Success criteria status**
   - Reference brief.md criteria
   - Design alignment with intent

4. **Known limitations**
   - Technical constraints identified
   - Trade-offs made

5. **Read order for Develop stage**
   - `intent.md` first (reference)
   - `brief.md` second (criteria)
   - `design.md` third (approach)
   - `BACKLOG.md` fourth (work items)
   - `status.md` for context

---

## Commit and Close

1. Archive working artifacts to `_archive/`
2. Update `status.md` with handoff block
3. Commit: `chore(design): stage complete — {summary}`
4. Run `/clear`

---

## Develop Stage Entry

The Develop stage agent should:
1. Read `CLAUDE.md` → `status.md` → `design.md` → `BACKLOG.md`
2. Understand architecture and work breakdown
3. Create `docs/adf/` workspace for planning artifacts
4. Begin implementation with clear guidance
