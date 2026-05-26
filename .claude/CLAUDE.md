---
owner: forge
---

# Claude memory (`.claude/` variant)

Canonical project context is in `../AGENTS.md`. The **root `CLAUDE.md` is the
Claude overlay and imports it** via `@AGENTS.md`.

This file is retained only as the `.claude/`-located memory variant. It
intentionally does **not** re-import `AGENTS.md`: Claude Code loads both this file
and the root `CLAUDE.md`, so importing here would double-load canonical context.
For project context, ownership, orientation sequence, and constraints, read
`../AGENTS.md`; for Claude-specific notes, see the root `CLAUDE.md`.
