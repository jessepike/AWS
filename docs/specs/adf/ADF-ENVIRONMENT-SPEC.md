---
type: "specification"
description: "Defines environment management — baseline detection, drift prevention, and setup for ADF projects"
version: "1.0.0"
updated: "2026-03-23"
scope: "adf"
lifecycle: "active"
supersedes: "ADF-ENV-PLUGIN-SPEC v1.0.0"
---

# ADF Environment Specification

## Summary

Environment management is a first-class concern. This spec defines what a healthy ADF environment looks like, how to detect drift, and how to restore baseline. Implemented as a skill (not a plugin).

---

## Taxonomy

| Term | Covers |
|------|--------|
| **Capabilities** | Skills, MCP servers, hooks |
| **Configuration** | settings.json, model preferences |
| **Context** | AGENTS.md, CLAUDE.md, .claude/rules/ |

---

## Baselines

### User Level (`~/.claude/`)

| Item | Requirement |
|------|-------------|
| `CLAUDE.md` | Required. Compact (<50 lines). Has constraints block. No project-specific content. |
| `settings.json` | Required. Has permissions block. |
| Skills | Only cross-project skills at user level. |
| Hooks | All user-level hooks declared. Undeclared hooks = drift. |

### Project Level

| Item | Requirement |
|------|-------------|
| `AGENTS.md` (root) | Required in dual-runtime mode. Shared source of truth for all runtimes. |
| `.claude/CLAUDE.md` | Required. Imports AGENTS.md via `@AGENTS.md`. Adds Claude-specific context only. |
| `.claude/rules/` | Optional. Project-specific constraints. Authoritative across all runtimes. |
| MCP servers | Project-specific only. Spun up by skills on demand. Zero always-on. |

---

## Drift Detection

Drift = actual state diverges from baseline. Two categories:

| Category | Examples | Severity |
|----------|----------|----------|
| **Missing** | Required file absent, expected skill not available | High |
| **Extra** | Undeclared hook, unexpected MCP server, stale config | Medium |
| **Stale** | CLAUDE.md references nonexistent files, outdated context map | Low |
| **Desync** | CLAUDE.md missing `@AGENTS.md` import, AGENTS.md missing required sections | Medium |

### Detection Approach

Environment health checks run via the `adf-env` skill. Not automatic — invoked on demand or at session start via lightweight hook.

**SessionStart hook** (`session-check.sh`):
- File existence checks only (<100ms, no network, no LLM calls)
- Checks: AGENTS.md exists (if dual-runtime), CLAUDE.md at both levels, settings.json, critical baseline markers
- Checks: CLAUDE.md contains `@AGENTS.md` import (if dual-runtime)
- Silent when clean — zero output, zero tokens
- Single warning line when drift detected

### Multi-Runtime Audit Checks

The `adf-env` skill audit includes cross-runtime validation:

| Check | What It Validates |
|-------|-------------------|
| AGENTS.md presence | Exists at project root (dual-runtime mode) |
| CLAUDE.md import | Contains `@AGENTS.md` import line |
| Claude-specific bloat | CLAUDE.md additions beyond import are minimal (<30 lines) |
| Dynamic state leakage | AGENTS.md and CLAUDE.md don't contain session state (belongs in status.md) |
| Governance consistency | .claude/rules/ constraints don't contradict AGENTS.md behavioral rules |

The adf-env skill orchestrates this. It delegates CLAUDE.md quality to claude-md-management (existing dependency), then runs multi-runtime checks on top.

---

## Skills

The `adf-env` skill provides:

| Command | Purpose |
|---------|---------|
| `status` | Scope-aware health dashboard (`--scope project` or `--scope user`) |
| `setup` | Smart setup with mode detection (first-time, new project, existing project) |
| `audit` | Deep environment validation |
| `reset` | Interactive reset to baseline with diffs and approval |

### Mode Detection (setup)

| Condition | Mode | Behavior |
|-----------|------|----------|
| No `~/.claude/CLAUDE.md` | First-time | Bootstrap user-level environment |
| Directory with no `.claude/` | New project | Initialize project-level environment |
| Directory with existing `.claude/` | Existing project | Audit and offer corrections |

---

## Dependencies

The `adf-env` skill delegates to:

| Dependency | Purpose | If Missing |
|------------|---------|------------|
| `claude-md-management` (plugin) | CLAUDE.md quality audit, drift detection | Warn, run built-in fallback |

**Graceful degradation:** Never silently fail. When a dependency is missing: surface explicit warning, run built-in fallback, suggest installation.

---

## Hooks

### SessionStart Hook

Lightweight file-existence check. Must complete in <100ms. No network calls, no plugin invocation, no LLM calls.

Checks:
- CLAUDE.md exists at user and project levels
- settings.json exists
- Critical baseline markers present

**Silent when clean.** Single warning line when drift detected.

### Stop Hook

Enforces session discipline:
- Uncommitted changes? → Agent must commit before ending.
- status.md not updated recently? → Agent must update before ending.

---

## Principles

| Principle | Application |
|-----------|-------------|
| YAGNI | Build only what's needed now |
| Minimal viable context | Smallest useful artifact |
| Progressive disclosure | Summary first, details on demand |
| Token-efficient | Every artifact earns its context cost |
| Graceful degradation | Never silently fail |
| Zero always-on MCP | Skills spin up MCP servers on demand, shut them down after |

---

## What This Spec Does NOT Cover

- **Spec content validation:** adf-env validates structure and presence, not correctness of spec content.
- **Prompt management:** Stage-specific prompts are a stage concern, not environment.
- **Cross-project learnings:** Deferred to memory/KB evaluation (Phase 4-5).
- **Intent drift detection:** Deferred. Would compare current work against intent.md — valuable but not v1.
