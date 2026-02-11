---
description: Archive rules for completed or superseded artifacts
globs: "**/*"
---

# Archive Rules

## When to Archive
- Backlog items that are completed or explicitly abandoned
- Superseded versions of architecture docs or briefs
- ADF stage artifacts that have been reviewed and closed

## How to Archive
- Move files to `.archive/` with date prefix: `YYYY-MM-DD_filename`
- Add a note in the original location pointing to the archived version if relevant
- Never delete — always archive

## Archive Structure
- `.archive/` — top-level archive for project artifacts
- `docs/adf/archive/` — ADF-specific stage artifacts
