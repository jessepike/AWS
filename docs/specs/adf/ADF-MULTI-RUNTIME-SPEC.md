---
type: "specification"
description: "Defines multi-model coexistence — Claude, Codex, and Gemini operating within ADF governance"
version: "2.0.0"
updated: "2026-03-23"
scope: "adf"
lifecycle: "active"
supersedes: "ADF-CODEX-COMPAT-SPEC v1.0.0, ADF-GEMINI-COMPAT-SPEC v1.0.0"
---

# ADF Multi-Runtime Specification

## Summary

ADF supports three agent runtimes. AGENTS.md is the shared source of truth for project instructions. CLAUDE.md imports AGENTS.md and adds Claude-specific context. All dynamic project state lives in shared artifacts — not in instruction files. Governance uses .claude/rules/ as the primary constraint layer.

---

## Instruction File Architecture

### AGENTS.md — Shared Source of Truth

AGENTS.md is the open standard for agent instructions (supported by Codex, Gemini, Cursor, Copilot, and 20+ tools). It contains all shared project context: behavioral constraints, workflow rules, build commands, architecture notes, and project-specific knowledge.

**What goes in AGENTS.md:**
- Project overview and architecture
- Build/test/lint commands
- Coding conventions and constraints
- ADF workflow rules (stage model, review requirements)
- Anything all runtimes need to know

**What does NOT go in AGENTS.md:**
- Dynamic session state (use status.md)
- Runtime-specific features (use runtime contract)
- LLM-generated boilerplate (ETH Zurich research: this can hinder agents)
- File structure descriptions (gets stale — agents can read the filesystem)

### CLAUDE.md — Claude-Specific Wrapper

Claude Code does not natively read AGENTS.md (feature request open, GitHub #6235). CLAUDE.md bridges the gap:

```markdown
# Project Context

@AGENTS.md

## Claude-Specific

<!-- Claude-only additions below -->
- Context map for progressive disclosure
- XML-aware prompting notes
- Claude Code feature usage (skills, hooks, MCP)
```

The `@AGENTS.md` import pulls in the shared instructions. Claude-specific additions are minimal (20-30 lines). **Edit AGENTS.md for shared context. Edit CLAUDE.md only for Claude-specific features.**

### Hierarchy

Both runtimes support hierarchical loading:

| Runtime | User Level | Project Level | Subdirectories |
|---------|-----------|---------------|----------------|
| Claude Code | `~/.claude/CLAUDE.md` | `.claude/CLAUDE.md` | CLAUDE.md in subdirs (on demand) |
| Codex | `~/.codex/AGENTS.md` | `AGENTS.md` at repo root | AGENTS.md in subdirs (walks down) |
| Gemini | — | `AGENTS.md` at repo root | AGENTS.md in parent dirs (walks up) |

---

## Runtime Contracts

| Runtime | Reads | Governance | Role |
|---------|-------|------------|------|
| Claude | CLAUDE.md (imports AGENTS.md) | `.claude/rules/` | Planning, review, architecture |
| Codex | AGENTS.md | `.claude/rules/` (manual), `~/.codex/rules/` (Starlark, optional) | Implementation |
| Gemini | AGENTS.md | `.claude/rules/` (manual) | Validation, review |

### Governance Layers

| Layer | Format | Scope | Status |
|-------|--------|-------|--------|
| `.claude/rules/` | Markdown + globs | Hard constraints, all runtimes | **Primary** — human-controlled, authoritative |
| `~/.codex/rules/` | Starlark | Codex command-level gating (allow/prompt/forbidden) | **Deferred** — evaluate when needed |
| `.cursor/rules/` | MDC | Cursor-specific rules | Out of scope |

**Current approach (option 2→3):** Behavioral governance lives in AGENTS.md (all runtimes read it). `.claude/rules/` enforces hard constraints for Claude sessions. Codex Starlark rules are deferred — evaluate if command-level gating becomes necessary. Captured in backlog.

---

## Static vs. Dynamic Context

**Critical design rule:** Instruction files (AGENTS.md, CLAUDE.md) carry static context — how agents should behave. Dynamic state — what's happening now — lives in shared project artifacts.

| Context Type | Where It Lives | Examples |
|-------------|----------------|----------|
| **Static** (instructions) | AGENTS.md, CLAUDE.md | Workflow rules, build commands, conventions |
| **Dynamic** (project state) | Shared artifacts | Current stage, recent decisions, blockers |

### Why This Matters for Multi-Runtime

If Claude updates CLAUDE.md mid-session (context map change, session learning), Codex doesn't see it — Codex reads AGENTS.md. And vice versa. Keeping dynamic state in shared artifacts eliminates this sync problem entirely.

### Shared Artifacts (All Runtimes Read/Write)

| Artifact | Purpose | Dynamic? |
|----------|---------|----------|
| `intent.md` | North Star | No (immutable) |
| `BACKLOG.md` | Work queue | Yes — items added/completed |
| `status.md` | Current state + handoff | Yes — updated every session |
| `decisions.md` | Decision log | Yes — decisions logged as made |
| `docs/active/*` | Working documents | Yes — current work product |
| `docs/reference/*` | Settled docs | Rarely changes |

**Handoff between runtimes** works through these artifacts. Claude finishes planning, updates status.md with handoff block, commits. Codex reads status.md, picks up implementation. No instruction file sync needed.

---

## Prompt Language

Shared contexts (BACKLOG.md, status.md, decisions.md, docs/) use runtime-neutral language:

- "Agent" not "Claude" or "Codex"
- "Review" not runtime-specific terminology
- "Browser automation" not "Claude in Chrome"

Runtime-specific contracts (CLAUDE.md, AGENTS.md) may use runtime-specific terminology.

---

## Bootstrap

Project initialization supports runtime selection:

| Flag | Creates | Use Case |
|------|---------|----------|
| `--runtime dual` (default) | `AGENTS.md` + `.claude/CLAUDE.md` (with @import) | Multi-model workflow |
| `--runtime claude-only` | `.claude/CLAUDE.md` only | Claude-only project |
| `--runtime codex-only` | `AGENTS.md` only | Codex-only project |

All modes create `.claude/rules/` — governance applies regardless of runtime.

In dual mode, CLAUDE.md is generated with `@AGENTS.md` import and a Claude-specific section stub.

---

## Workflow Model

The recommended multi-model workflow:

| Phase | Runtime | Why |
|-------|---------|-----|
| Planning & specs | Claude (Opus) | Strong reasoning, architectural thinking |
| Implementation | Codex | Fast execution, code generation |
| Review & validation | Claude or Gemini | Independent perspective, quality gates |

This is a recommendation, not a constraint. Any runtime can do any phase.

---

## Conflict Resolution

If runtime contracts disagree with each other or with project artifacts:

1. `.claude/rules/` wins (always)
2. Project artifacts (intent.md, BACKLOG.md) win over runtime contracts
3. AGENTS.md wins over runtime-specific additions in CLAUDE.md (shared > specific)
4. Runtime-specific contracts govern only their own runtime's behavior
5. When in doubt, the human decides

---

## What This Spec Does NOT Cover

- **MCP API naming:** Tool names remain as-is (e.g., `claude_md`). Neutral aliases are deferred.
- **Runtime-specific capabilities:** What each model is good at evolves rapidly. This spec doesn't benchmark.
- **Agent orchestration:** How models hand off is a workflow concern. Parallel agent coordination (worktrees, etc.) is deferred.
- **Codex Starlark rules:** Deferred. Evaluate if command-level gating is needed. See backlog.
