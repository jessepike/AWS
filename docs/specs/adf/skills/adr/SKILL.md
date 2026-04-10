---
name: ADR
description: This skill should be used when the user asks to "create an ADR", "record a decision", "new architecture decision", "list ADRs", "show decisions", "update ADR status", "deprecate ADR", "supersede ADR", or when the user needs to formally document a significant technical decision.
version: 1.0.0
user_invocable: true
arguments:
  - name: action
    description: "Action to perform: create, list, update-status, link"
    required: false
  - name: title
    description: "Decision title (for create action)"
    required: false
  - name: number
    description: "ADR number (for update-status/link actions)"
    required: false
  - name: status
    description: "New status: accepted, deprecated, superseded (for update-status action)"
    required: false
---

# ADR Skill

Manages Architecture Decision Records (ADRs) as ADF `decision`-type artifacts in `docs/decisions/`.

## Purpose

Provide a formal, structured way to capture significant technical decisions with context, alternatives considered, and consequences. ADRs complement the Decision Log in `design.md` by giving complex decisions their own artifact with full rationale.

## When to Use

**Create an ADR when a decision:**
- Affects 3+ components or modules
- Is hard to reverse once implemented
- Had multiple viable options seriously debated
- Changes an existing architectural pattern
- Will be questioned by future contributors

**Keep in design.md Decision Log when:**
- Decision is straightforward with an obvious best choice
- Scope is limited to a single component
- Context is simple enough for a one-line rationale

When in doubt, start in the Decision Log. Graduate to an ADR if the rationale grows beyond 3-4 sentences.

## Stage Awareness

- **Design stage** — Primary stage for ADRs. Most architectural decisions happen here.
- **Develop stage** — Implementation may surface decisions not anticipated in Design.
- **Discover/Deliver** — Rare. Only if a fundamental constraint or delivery decision needs formal capture.

## Workflows

### Create ADR

**Trigger:** `/adr create "Decision title"` or "create an ADR for..."

1. **Ensure directory exists:**
   - Check for `docs/decisions/` — create if missing
2. **Determine next number:**
   - Scan `docs/decisions/ADR-*.md` for highest existing number
   - Next number = highest + 1 (or 001 if none exist)
   - Zero-pad to 3 digits: `001`, `002`, etc.
3. **Generate filename:**
   - `ADR-NNN-kebab-case-title.md`
   - Example: `ADR-003-use-postgresql-for-persistence.md`
4. **Populate from template:**
   - Use the template from `references/adr-template.md`
   - Fill in: number, title, date, status (Proposed), description
   - Pre-populate Context and Decision Drivers from conversation context if available
5. **Write file** to `docs/decisions/`
6. **Commit:**
   ```
   docs(adr): ADR-NNN short description
   ```
7. **Report** — Display the file path and suggest next steps (fill in options, link to design.md)

### List ADRs

**Trigger:** `/adr list` or "show ADRs" or "list decisions"

1. **Scan** `docs/decisions/ADR-*.md`
2. **Read frontmatter** from each file (title, status, date)
3. **Display table:**

```
| # | Title | Status | Date |
|---|-------|--------|------|
| ADR-001 | Use PostgreSQL for persistence | Accepted | 2026-01-15 |
| ADR-002 | Event-driven architecture | Proposed | 2026-01-20 |
| ADR-003 | JWT for authentication | Deprecated | 2026-02-01 |
```

4. If no ADRs exist, report "No ADRs found in `docs/decisions/`."

### Update ADR Status

**Trigger:** `/adr update-status NNN accepted` or "deprecate ADR-002"

**Valid transitions:**
```
Proposed → Accepted
Proposed → Deprecated
Accepted → Deprecated
Accepted → Superseded
```

**Invalid transitions** (reject with explanation):
- Deprecated → Accepted (create a new ADR instead)
- Superseded → Accepted (create a new ADR instead)
- Any → Proposed (Proposed is initial state only)

**Steps:**

1. **Locate** `docs/decisions/ADR-NNN-*.md`
2. **Validate** the transition is allowed
3. **Update frontmatter:**
   - Set `status` to new value
   - Set `updated` to today's date
4. **For Deprecated/Superseded:**
   - Add note in Consequences section explaining why
   - If superseded, add `superseded_by: ADR-NNN` to frontmatter
   - Move file to `.archive/YYYY-MM-DD-ADR-NNN-title.md`
5. **Commit:**
   ```
   docs(adr): ADR-NNN mark as {status}
   ```

### Link ADR to Design

**Trigger:** `/adr link NNN` or "link ADR to design"

1. **Read** `docs/design.md` and locate the Decision Log section
2. **Check** if ADR is already referenced
3. **Add entry** to Decision Log table:
   ```
   | Decision Title | ADR-NNN | YYYY-MM-DD | Brief rationale |
   ```
4. **Commit:**
   ```
   docs(adr): link ADR-NNN to design.md Decision Log
   ```

## ADR Template (Condensed)

Each ADR follows this structure (full template in `references/adr-template.md`):

```yaml
---
type: "decision"
title: "ADR-NNN: Decision Title"
status: "Proposed"          # Proposed | Accepted | Deprecated | Superseded
date: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
description: "One-line summary"
decision_makers: []
related_adrs: []
---
```

**Sections:** Context, Decision Drivers, Considered Options (with pros/cons), Decision, Consequences (positive/negative/neutral), ADF Integration Notes

## Integration Points

### design.md Decision Log
- ADRs are the detailed backing for Decision Log entries
- Link action connects the two
- Decision Log provides the summary; ADR provides the full rationale

### ADF Stage Flow
- ADRs created primarily in Design, occasionally in Develop
- Status updates may happen at any stage
- Review process may surface need for new ADRs

### Archive Rules
- Deprecated and Superseded ADRs move to `.archive/` per archive rules
- Naming: `.archive/YYYY-MM-DD-ADR-NNN-title.md`
- Active ADRs (Proposed, Accepted) stay in `docs/decisions/`

### ADF Artifact Spec
- ADRs use `type: "decision"` (per ADF-CONTEXT-ARTIFACT-SPEC controlled vocabulary)
- Follow standard frontmatter schema
- Located at `docs/decisions/` (per ADF-FOLDER-STRUCTURE-SPEC)

## Error Handling

### Missing Directory
- `docs/decisions/` doesn't exist → create it automatically on first ADR

### Numbering Conflict
- Gap in numbers (e.g., 001, 003) → use next sequential (004), don't fill gaps
- Archived ADRs still count — never reuse a number

### Invalid Status Transition
- Explain which transitions are valid
- Suggest creating a new ADR if trying to reactivate a deprecated/superseded one

### No design.md for Link
- If `docs/design.md` doesn't exist, warn and skip the link action
- Suggest creating the ADR standalone and linking later

## Quick Reference

**Trigger phrases:**
- "create an ADR", "record a decision", "new architecture decision"
- "list ADRs", "show decisions"
- "update ADR status", "accept ADR", "deprecate ADR", "supersede ADR"
- "link ADR to design"

**File convention:** `docs/decisions/ADR-NNN-kebab-case-title.md`

**Status lifecycle:**
```
Proposed → Accepted → Deprecated
                   → Superseded
```

**Commit format:** `docs(adr): ADR-NNN description`

**Frontmatter type:** `decision` (ADF controlled vocabulary)
