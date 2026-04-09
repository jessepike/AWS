# Lessons — Agentic Work System

Hot buffer of insights, patterns, and gotchas from recent sessions. One line per insight, dated. Keep last ~15. Promote cross-project patterns to KB at session wrap.

## 2026-04-09

- `architecture.md` is read-only — any proposed changes must go through CTO review before editing. Treat it as an ADR, not a living doc.
- The CMM maturity model (added 2026-04-07) provides a measurable ladder for each Knowledge Ring component — reference it when evaluating Phase 0a → 0b gate.

## 2026-04-07

- KB and Memory observability scores updated after Phase 2 — canonical job registry (35 jobs: 17 launchd + 18 NC) is now the single source of truth for scheduled work. Always check it before adding new jobs.
- The Why/Realized cascade in the backlog (B30) allows backlog items to trace from user intent through to actual implementation — valuable pattern for trust ladder validation.
