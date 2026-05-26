---
owner: forge
---

@AGENTS.md

# Claude-specific notes

Canonical project context lives in `AGENTS.md` (imported above). Only
Claude-specific rules belong here.

- **Hard constraints:** see `.claude/rules/` (`archive.md`, `constraints.md`) —
  archive-never-delete, no edits to `.claude/rules/` or `docs/intent.md` without
  approval, confirm before destructive operations, read `docs/status.md` at
  session start and update it at session end.
- **Dev-system ownership:** aws is Forge-owned governance. Other agents are
  read-only; route standards/spec/ADR changes through Forge
  (`~/.claude/rules/dev-system-ownership.md`).
- This root `CLAUDE.md` is the primary Claude overlay and the **importer** of
  canonical context; `.claude/CLAUDE.md` is a thin pointer that does not re-import
  (avoids double-loading `AGENTS.md`).
