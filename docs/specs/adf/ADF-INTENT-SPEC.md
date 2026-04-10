---
type: "specification"
description: "Defines the intent.md artifact — the project's North Star"
version: "1.0.1"
updated: "2026-01-24"
scope: "adf"
lifecycle: "reference"
location: "adf/ADF-INTENT-SPEC.md"
---

# ADF Intent Specification

## Purpose

Define `intent.md` — the single, stable statement of what a project is trying to accomplish and why.

## What Intent Is

**The North Star.** A concise statement that all agents, humans, and stages align to.

- Answers: "What are we trying to accomplish and why?"
- Stable: Rarely changes once established
- Authoritative: Decisions can be validated against it ("Does this serve the intent?")

## What Intent Is Not

- Not the detailed scope (that's `brief.md`)
- Not the approach or how (that's Design)
- Not a living document that evolves frequently
- Not a place for constraints, risks, or implementation details

## Content

Intent.md contains **three elements**:

| Element | Description | Example |
|---------|-------------|---------|
| **Problem/Opportunity** | What situation prompted this project? | "Agents lose context between sessions, causing repeated work and drift." |
| **Desired Outcome** | What does success look like at the highest level? | "Agents maintain alignment across sessions without human re-explanation." |
| **Why It Matters** | Why is this worth doing? | "Reduces friction, improves quality, enables longer autonomous work." |

## Format

```markdown
---
type: "intent"
description: "Project intent statement"
version: "1.0.0"
updated: "YYYY-MM-DD"
---

# Intent: [Project Name]

## Problem/Opportunity
[1-3 sentences]

## Desired Outcome
[1-3 sentences]

## Why It Matters
[1-3 sentences]
```

**Target length:** 50-150 words total (excluding frontmatter).

## Governance

| Aspect | Rule |
|--------|------|
| Created | Discover stage |
| Modified by | Human only (or with explicit approval) |
| Change frequency | Rarely — intent drift is a red flag |
| Change process | Future: change control / approval gate |

## Validation Criteria

A strong intent statement:

- [ ] Can be understood by a new agent with no prior context
- [ ] Is specific enough to validate decisions against
- [ ] Is stable enough to survive the project lifecycle
- [ ] Fits in ~100 words (not a wall of text)
- [ ] Avoids implementation details (no "how")

## Relationship to Other Artifacts

| Artifact | Relationship |
|----------|--------------|
| `brief.md` | Brief expands on intent with scope, success criteria, boundaries |
| `CLAUDE.md` | Project CLAUDE.md references intent as the governing purpose |
| Design artifacts | Design decisions should trace back to intent |

## Open Questions

- Should intent.md merge into brief.md as the top section? (Deferred — keep separate for now)
- What's the formal change control process? (Deferred — conceptual for now)

## References

- ADF-STAGES-SPEC.md (Discover stage outputs intent.md)
- ADF-GLOBAL-PRIMITIVES-v0.1.md
