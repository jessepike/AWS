---
type: "transition-prompt"
description: "Guidance for transitioning from Discover to Design stage"
from_stage: "discover"
to_stage: "design"
version: "1.0.0"
updated: "2026-02-03"
---

# Discover → Design Transition

## Prerequisites

Before transitioning from Discover to Design, verify:

- [ ] `intent.md` exists and is crystal clear
- [ ] `brief.md` exists with success criteria defined
- [ ] All discovery work committed
- [ ] No critical or high issues open from review

---

## Artifact Cleanup Checklist

### Deliverables (Keep Active)
These artifacts carry forward to Design:
- `intent.md` — North Star reference
- `brief.md` — Scope and criteria
- `status.md` — Updated with handoff

### Working Artifacts (Archive)
Move these to `_archive/` with naming `_archive/YYYY-MM-DD-<name>.md`:
- Concept briefs (if created)
- Discovery briefs (if separate from final brief)
- Research spike notes
- Exploration documents
- Draft intent versions

**Action:** Execute cleanup before updating status.md

---

## Status Update Requirements

Update `status.md` with:

1. **What was produced**
   - Summary of intent.md and brief.md
   - Key files created

2. **What was archived**
   - List of archived artifacts
   - Rationale for each

3. **Success criteria status**
   - Reference brief.md criteria
   - Note any deferred items

4. **Known limitations**
   - Uncertainties to resolve in Design
   - Assumptions made

5. **Read order for Design stage**
   - `intent.md` first
   - `brief.md` second
   - `status.md` for context

---

## Commit and Close

1. Archive working artifacts to `_archive/`
2. Update `status.md` with handoff block
3. Commit: `chore(discover): stage complete — {summary}`
4. Run `/clear`

---

## Design Stage Entry

The Design stage agent should:
1. Read `CLAUDE.md` → `status.md` → `intent.md` → `brief.md`
2. Understand what was produced and archived
3. Begin design work with clear context
