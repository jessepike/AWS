---
type: "prompt"
description: "One-off correction prompt to fix planning artifacts before implementation"
version: "1.0.0"
updated: "2026-01-28"
scope: "develop"
usage: "Use when planning artifacts need restructuring before proceeding to execution"
---

# Develop Artifact Correction Prompt

## Purpose

Correct planning artifacts (capabilities.md, tasks.md) to meet ADF spec requirements before proceeding to implementation.

---

## Prompt

Before we proceed to implementation, we need to correct the planning artifacts to ensure they're actionable.

## Issue 1: capabilities.md Structure

The current capabilities.md describes what we're building, not what agent infrastructure is needed to build it.

**Restructure capabilities.md with these required sections:**

### MCP Servers

| Server | Purpose | Source |
|--------|---------|--------|
| [server-name] | [what it provides] | [registry path OR "manual"] |

Example: `context7-mcp | Astro documentation lookup | manual (not in registry)`

### Skills

| Skill | Purpose | Source |
|-------|---------|--------|
| [skill-name] | [what procedural knowledge it provides] | [registry path] |

Example: `frontend-design | UI component patterns | registry: capabilities/skills/frontend-design`

### Sub-agents

| Agent | Role | When Used |
|-------|------|-----------|
| [agent-name] | [specialization] | [trigger condition] |

Or: "None required for this project."

### CLIs & Tools

| Tool | Purpose | Install Method |
|------|---------|----------------|
| [tool-name] | [what it does] | [how to get it] |

Example: `npm | Package management | Bundled with Node.js`

### Testing Capabilities

| Capability | Purpose |
|------------|---------|
| [tool/framework] | [what it validates] |

Example: `Playwright | E2E browser testing`

---

## Issue 2: tasks.md Status Tracking

Tasks need a status column to track completion.

**Add status column to all task tables:**

| ID | Task | Status | Acceptance Criteria | Depends |
|----|------|--------|---------------------|---------|
| 1.1 | [task] | pending | [criteria] | [deps] |

**Status values:** `pending`, `in_progress`, `done`, `blocked`

---

## Issue 3: Task-to-Capability Mapping (Optional but Recommended)

Add a Capability column to link tasks to required capabilities:

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| 1.1 | [task] | pending | [criteria] | [deps] | [skill/tool needed] |

This validates that the agent has what it needs for each task.

---

## Your Task

1. **Restructure capabilities.md** with the sections above
   - For each capability, identify: Is it in a registry? Manual specification?
   - Be specific about MCP servers, skills, CLIs needed
   - If no registry available, manually specify what's needed

2. **Add status column to tasks.md**
   - All tasks start as `pending`
   - Optionally add Capability column

3. **Present updated artifacts** for approval before proceeding

---

## Registry Reference

Query the capabilities registry at `~/code/_shared/capabilities-registry/`:
- Read `INVENTORY.md` for available skills, tools, and plugins
- Match available capabilities to project requirements
- Note registry paths for sourced capabilities (e.g., `capabilities/skills/frontend-design`)
- Flag gaps that need manual specification

---

## Exit Criteria

- [ ] capabilities.md has all required sections (MCP Servers, Skills, Sub-agents, CLIs, Testing)
- [ ] Each capability has a source (registry path or manual)
- [ ] tasks.md has Status column on all tables
- [ ] Human approves corrected artifacts
