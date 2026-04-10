---
type: "context"
description: "ADF project context — the agentic context management framework"
version: "2.1.0"
updated: "2026-02-04"
scope: "project"
lifecycle: "reference"
location: ".claude/CLAUDE.md"
---

# ADF Project Context

## What This Is

ADF (Agentic Development Framework) is the framework that defines how agentic projects are structured, managed, and maintained. It owns orchestration, knowledge, and the specs that govern all stages.

## Current Stage

**Develop** — building out the ADF framework itself and its environment layer.

## Orientation

1. `.claude/rules/` — Hard constraints (read first, always enforced)
2. `status.md` — Current state, session log, next steps
3. `BACKLOG.md` — All tracked work items

## Stage Flow

Stages: Discover → Design → Develop → Deliver

Each stage follows: **Work → Review → Update → Validate → Close out → Transition**

- Query `get_stage()` from ADF MCP for phase details at each stage
- Review is an orchestration-layer service — use adf-review skill (default: full review)
- At phase boundaries: update handoff block in tasks.md, commit, `/clear`
- At stage boundaries: verify exit criteria via `check_project_health()`, update status.md

## Related Repos

| Repo | Location |
|------|----------|
| capabilities-registry | `~/code/_shared/capabilities-registry/` |
| link-triage-pipeline | `~/code/_shared/link-triage-pipeline/` |
| adf-env plugin | `~/.claude/plugins/adf-plugins/plugins/adf-env/` |

## Working Norms

- Token-efficient — every artifact earns its context cost
- Progressive disclosure — summary first, details on demand via MCP
