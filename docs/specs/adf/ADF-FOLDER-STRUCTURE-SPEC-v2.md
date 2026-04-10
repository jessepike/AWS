---
type: "specification"
description: "Defines folder structure for ADF projects — three-tier context model with lifecycle management"
version: "2.0.0"
updated: "2026-03-23"
scope: "adf"
lifecycle: "active"
supersedes: "ADF-FOLDER-STRUCTURE-SPEC v1.2.0"
---

# ADF Folder Structure Specification v2

## Summary

Three-tier context model for agentic projects. First-class artifacts at root (always visible to agents). Lifecycle-managed docs folder (active → reference → archive). Ephemeral agent scratch space (`.ctx/`, gitignored). Progressive disclosure via CLAUDE.md context map.

---

## Design Principles

**Root = North Star.** First-class artifacts live at project root. Always visible. Never buried.

**Lifecycle over location.** Documents flow through stages: inbox → active → reference → archive. Location reflects current lifecycle state.

**Progressive disclosure.** Agents load minimal context by default (root artifacts + `docs/active/`). Deeper context loaded on demand via CLAUDE.md context map.

**Flat over deep.** No nesting beyond two levels in docs/. Add depth only when it earns its place.

**Ephemeral is ephemeral.** `.ctx/` is gitignored scratch space. Nothing in it should be load-bearing.

---

## Base Structure (All Projects)

```
project-root/
├── AGENTS.md                     # Shared instructions (all runtimes)
├── CLAUDE.md                     # Claude wrapper (@AGENTS.md import + Claude-specific)
├── intent.md                     # North Star — immutable without permission
├── BACKLOG.md                    # Canonical work items
├── status.md                     # Current project state
├── decisions.md                  # Decision log (date, decision, rationale)
├── README.md                     # What this is, how to use it
├── .claude/
│   └── rules/                    # Governing rules (human-controlled)
├── docs/
│   ├── inbox/                    # Triage zone — new/unprocessed items
│   ├── active/                   # Agent working zone — current docs
│   ├── reference/                # Settled docs — lookup only
│   └── archive/                  # Historical — agents don't read without instruction
├── .ctx/                         # Ephemeral agent scratch (gitignored)
└── .gitignore
```

**Root artifacts (7):** Always visible. These are the project's vital signs.

**docs/ (4 lifecycle folders):** Where all project documentation lives, organized by lifecycle state.

**`.ctx/` (1):** Agent scratch space. Gitignored. Session-scoped working memory.

---

## Root Artifacts

| File | Purpose | Who Writes | Protection |
|------|---------|------------|------------|
| `AGENTS.md` | Shared project instructions for all runtimes (Claude, Codex, Gemini) | Human + Agent | Agent-writable |
| `CLAUDE.md` | Claude-specific wrapper — `@AGENTS.md` import + context map | Agent + Human | Agent-writable |
| `intent.md` | North Star — overarching intent and outcomes | Human only | **Immutable** — agents CANNOT modify without explicit permission |
| `BACKLOG.md` | Canonical list of work items, priorities | Human + Agent | Agent-writable |
| `status.md` | Current state — what's happening, what stage, blockers | Agent | Agent-writable |
| `decisions.md` | Decision log — date, decision, rationale, who decided | Human + Agent | Agent-writable |
| `README.md` | External-facing: what this project is, how to use it | Human + Agent | Agent-writable |

**Why root?** Agents see these immediately. No path-hunting. No "where did we put status again?" Root = always in context.

---

## Document Lifecycle

### Flow

```
New item → docs/inbox/ → [triage] → docs/active/
                                         ↓
                                   [work completes]
                                         ↓
                                   docs/reference/  (still useful, settled)
                                         or
                                   docs/archive/    (historical only)
```

### Lifecycle Folders

| Folder | Purpose | Agent Behavior |
|--------|---------|----------------|
| `docs/inbox/` | Triage zone. New items land here. | Agents process and route items out. |
| `docs/active/` | **Agent loading zone.** Current working docs. | **Default read/write zone.** Agents look here first for project docs. |
| `docs/reference/` | Settled documentation. Lookup only. | Agents read when directed or when CLAUDE.md context map points here. |
| `docs/archive/` | Historical. Superseded or completed docs. | **Write-only for agents.** Do not read without explicit user instruction. |

### Agent Default: `docs/active/`

When an agent needs to find or create a project document, it goes to `docs/active/` unless told otherwise. This is the working zone. Feature specs, planning docs, technical designs, implementation plans — all live here while being actively worked on.

### What Lives Where

**`docs/active/` (current work):**
- `brief.md` — scope, success criteria, constraints
- `design.md` — architecture, component design
- `implementation-plan.md` — how we're building it
- `feature-*.md` — individual feature specs
- `research-*.md` — active research/analysis
- Any doc currently being referenced or worked on

**`docs/reference/` (settled, lookup):**
- Completed ADRs
- API documentation
- Dependency documentation
- Onboarding guides
- Anything agents might need to look up but won't modify

**`docs/archive/` (historical):**
- Superseded designs
- Old planning artifacts
- Completed feature specs (after ship)
- Previous versions of active docs

**`docs/inbox/` (triage):**
- New context from external sources
- Unprocessed feedback
- Items awaiting categorization

---

## Ephemeral Context: `.ctx/`

`.ctx/` is **context** — ephemeral agent scratch space, gitignored.

```
.ctx/                             # Gitignored
├── scratch/                      # Free-form agent working notes
├── plans/                        # Expanded implementation plans (session-scoped)
└── research/                     # Intermediate research, draft analysis
```

**Rules:**
- Gitignored. Never committed.
- Agents write here freely during a session.
- Nothing in `.ctx/` should be load-bearing. If it matters, it moves to `docs/active/`.
- Cleaned up between sessions (or left to rot — it's gitignored).
- No ownership rules. Any agent can read/write.

**Use cases:**
- Agent expands a BACKLOG item into a detailed plan before writing it to `docs/active/implementation-plan.md`
- Agent dumps intermediate research before synthesizing into a deliverable
- Multi-step reasoning artifacts that support a final output
- Draft content before review/promotion

---

## Type-Specific Additions

### Software Projects

```
project-root/
├── [base structure]
├── src/                          # Source code
├── tests/                        # Test files
├── config/                       # Configuration files
├── scripts/                      # Build/deploy automation
└── Makefile                      # Standard commands
```

### Artifact Projects

```
project-root/
├── [base structure]
├── assets/                       # Images, data files, source materials
└── output/                       # Generated artifacts (deliverables)
```

### Workflow Projects

```
project-root/
├── [base structure]
├── workflows/                    # Pipeline/process definitions
└── scripts/                      # Supporting automation
```

---

## CLAUDE.md Context Map

CLAUDE.md includes a context map that tells agents what to load and when. This enables progressive disclosure — agents start with root artifacts and `docs/active/`, then expand as needed.

Example context map section in CLAUDE.md:

```markdown
## Context Map

**Always loaded:** Root artifacts (intent.md, BACKLOG.md, status.md, decisions.md)
**Default working zone:** docs/active/
**Load on demand:**
- API details → docs/reference/api-docs.md
- Architecture decisions → docs/reference/adrs/
- Feature specs → docs/active/feature-*.md
**Never load automatically:** docs/archive/ (explicit instruction only)
```

---

## Naming Conventions

**Document names describe WHAT, not WHICH STAGE.**

- ✅ `brief.md` — describes what it is
- ❌ `discover-brief.md` — couples name to stage
- ✅ `design.md` (splits to `design-architecture.md`, `design-frontend.md`, etc. at 500+ lines)
- ❌ `design-stage-design.md`
- ✅ `implementation-plan.md`
- ❌ `develop-plan.md`

Stage provenance can go in frontmatter if needed:

```markdown
---
stage: discover
created: 2026-03-23
---
```

---

## Migration from v1

| v1 | v2 | Change |
|----|-----|--------|
| `docs/intent.md` | `intent.md` (root) | Promoted to root — always visible |
| `docs/brief.md` | `docs/active/brief.md` | Renamed, moved to lifecycle folder |
| `docs/status.md` | `status.md` (root) | Promoted to root |
| `docs/tasks.md` | `BACKLOG.md` (root) | Renamed, promoted to root |
| `docs/adf/` | `.ctx/` | Replaced — ephemeral scratch is now gitignored |
| `docs/adf/archive/` | `docs/archive/` | Moved to lifecycle folder |
| `.archive/` (root) | `docs/archive/` | Consolidated into docs lifecycle |
| `docs/inbox/` | `docs/inbox/` | Unchanged |
| (none) | `docs/active/` | New — agent default working zone |
| (none) | `docs/reference/` | New — settled docs, lookup only |
| (none) | `decisions.md` (root) | New — decision log at root |

---

## Scaffolding

```bash
# Base (all projects)
mkdir -p .claude/rules docs/inbox docs/active docs/reference docs/archive .ctx/scratch .ctx/plans .ctx/research
touch AGENTS.md CLAUDE.md intent.md BACKLOG.md status.md decisions.md README.md .gitignore

# Add to .gitignore
echo ".ctx/" >> .gitignore

# Software
mkdir -p src tests config scripts && touch Makefile

# Artifact
mkdir -p assets output

# Workflow
mkdir -p workflows scripts
```

---

## Validation Checklist

Before exiting project init:

- [ ] `CLAUDE.md` exists with context map
- [ ] `intent.md` exists (stub OK)
- [ ] `BACKLOG.md` exists (stub OK)
- [ ] `status.md` exists (stub OK)
- [ ] `decisions.md` exists (stub OK)
- [ ] `README.md` exists (stub OK)
- [ ] `docs/inbox/` exists
- [ ] `docs/active/` exists
- [ ] `docs/reference/` exists
- [ ] `docs/archive/` exists
- [ ] `.ctx/` exists and is gitignored
- [ ] `.claude/rules/` exists
- [ ] Type-specific folders created
- [ ] `.gitignore` includes `.ctx/`

---

## Maintenance

### Promotion Triggers

| Event | Action |
|-------|--------|
| Stage transition | Review `docs/active/`, promote settled docs to `reference/` |
| Feature ships | Move feature spec from `active/` to `archive/` |
| Decision made | Log in `decisions.md`, move analysis to `reference/` |
| Context bloat | Audit `docs/active/`, demote stale items |
| Session end | Clean `.ctx/` (optional — it's gitignored anyway) |

### Archive Rules

Same as v1:
- Agents may move files TO `docs/archive/`
- Agents MUST NOT read from `docs/archive/` without explicit user instruction
- Archive naming: `YYYY-MM-DD-<artifact-name>.md`
