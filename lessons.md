# Lessons — Agentic Work System

Hot buffer of insights, patterns, and gotchas from recent sessions. One line per insight, dated. Keep last ~15. Promote cross-project patterns to KB at session wrap.

## 2026-04-10 (governance sprint Day 2)

- Portfolio audit before conformance standardization is expected to show 0% compliance — baseline value comes from the structured remediation list, not the initial score.
- Standards that fight reality lose. `project-layout.yaml` required root-level `intent.md`, but 10/13 Tier 1 projects used `docs/intent.md`. Updating the standard (alt_paths) instantly fixed ~40% of drift. Audit projects before writing standards.
- Subagent outputs need verification against known corrections — a subagent reading updated standard v1.1.0 still reported `docs/intent.md` as a violation. Explicit context in prompts is not guaranteed to internalize.
- `workflow-change-detector` hook false positive rate is high with broad trigger patterns. Non-blocking mode is mandatory for hooks that may fire on benign input. Tune patterns after observing real-session behavior.
- Building governance tooling as readable SKILL.md files (not binaries) is the right pattern — any agent can read and follow the instructions. `/project-doctor` is a reference document, not an executable.
- Bulk conformance fixes are high-leverage: 13 files + 10 dirs across 11 projects in one session moved portfolio from 0% to ~73% at minor-or-better. Automated baseline → bulk remediation → human-judgment pass is the right sequence.

## 2026-04-09

- AWS vs AGF clarification: AWS is Jesse's personal OS for daily work; AGF is the commercial client framework. Inspiration relationship only — not parent/child. Keep them separate.
- Symlink-first migration is the right shape for risky directory moves — safety net during transition, removal as a follow-up backlog item once verified stable.
- Forge as exclusive write-authority on AWS components eliminates "which agent for this?" decisions — single ownership = lower cognitive load.
- Existing pike-agent capability schema uses `source: internal` not `source: pike-agents`. Schema drift between handoff spec and live pattern caught at registration time — verify schema before writing new capability.yaml files.
- Phase 1 + Phase 2 + Phase 7 ran in parallel (subagent + 2 inline) — solid pattern for spec-heavy sprints with independent phases. Apply to future multi-phase governance work.
- `architecture.md` is read-only — any proposed changes must go through CTO review before editing. Treat it as an ADR, not a living doc.
- The CMM maturity model (added 2026-04-07) provides a measurable ladder for each Knowledge Ring component — reference it when evaluating Phase 0a → 0b gate.

## 2026-04-07

- KB and Memory observability scores updated after Phase 2 — canonical job registry (35 jobs: 17 launchd + 18 NC) is now the single source of truth for scheduled work. Always check it before adding new jobs.
- The Why/Realized cascade in the backlog (B30) allows backlog items to trace from user intent through to actual implementation — valuable pattern for trust ladder validation.
