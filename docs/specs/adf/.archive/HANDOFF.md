---
type: "handoff"
description: "Session handoff for ACM development continuity"
version: "1.0.0"
updated: "2026-01-25"
lifecycle: "ephemeral"
location: "acm/HANDOFF.md"
---

# ACM Development Handoff

## Project Intent

**ACM (Agentic Context Management)** is a minimal scaffolding system for managed agentic workflows. It provides the irreducible primitives needed to maintain context, structure, and alignment across agent sessions — applicable to any project type (software, artifacts, workflows).

**Philosophy:** Goldilocks approach — not too much, not too little. Build minimal viable layers and iterate.

---

## Current State: ACM Base Layer Complete

We've built the foundational "Base Layer" — the global context harness that applies to all projects.

### What's Built

| Artifact | Purpose | Location |
|----------|---------|----------|
| **Global CLAUDE.md** | Universal guardrails, orientation, structure | `~/.claude/CLAUDE.md` |
| **ACM-CONTEXT-ARTIFACT-SPEC** | Frontmatter, progressive disclosure, lifecycle | `acm/` |
| **ACM-INTENT-SPEC** | Intent.md definition (North Star) | `acm/` |
| **ACM-BRIEF-SPEC** | Brief.md definition (scope/criteria) | `acm/` |
| **ACM-PROJECT-TYPES-SPEC** | Software / Artifact / Workflow | `acm/` |
| **ACM-FOLDER-STRUCTURE-SPEC** | Base + type-specific folders | `acm/` |
| **ACM-STAGES-SPEC** | Stage workflow overview (not detailed) | `acm/` |
| **ACM-GLOBAL-CLAUDE-MD-SPEC** | What goes in global CLAUDE.md | `acm/` |
| **ACM-PROJECT-CLAUDE-MD-SPEC** | What goes in project CLAUDE.md | `acm/` |
| **init-project.sh** | Interactive scaffolding script | `acm/scripts/` |
| **Templates** | intent.md, brief.md, project CLAUDE.md starters | `acm/templates/` |
| **Prompts** | Architecture diagram generation prompts | `acm/prompts/` |

### Deployment Location

- **Production:** `/Users/jessepike/code/_shared/acm/` — ready to use
- **Development:** `/code/tools/agent-harness` and `/code/ack` — iteration repos

---

## Key Decisions Made

1. **Three project types:** Software, Artifact, Workflow — broad categories, sub-variations determined in Design

2. **Intent.md is #1 artifact:** North Star, human-controlled, rarely changes, governs everything

3. **Brief.md is the detailed contract:** Scope, success criteria, constraints — evolves through stages

4. **Global CLAUDE.md is minimal:** ~65 lines, only universal content, <300 lines best practice

5. **Artifact lifecycle:** Deliverable (never prune), Reference (archive when obsolete), Inbox (triage zone), Archive (preserved but inactive)

6. **Stage model deferred from global:** Stages (Discover → Design → Develop → Deliver) are project-level, not global guardrails

7. **Validators/maintenance deferred:** `acm-validate` and `acm-prune` skills documented but not built — build after real usage

8. **Context Layer = Tier-1 Memory:** Global + Project CLAUDE.md files

---

## What's Next: Stage Development

The Base Layer is complete. Next: Define each stage in detail.

**Recommended order:**
1. **Discover stage** — What are we trying to accomplish? Outputs intent.md, brief.md
2. **Design stage** — How will we approach it? Approach decisions
3. **Develop stage** — Build correctly. Execution patterns
4. **Deliver stage** — Done and usable. Handoff/release

**For each stage, define:**
- Key question
- Inputs required
- Outputs/deliverables
- Supporting capabilities (skills, prompts, tools)
- Exit criteria
- How intent.md and brief.md are used

---

## Entry Points for New Agent

**Read in this order:**

1. `acm/CLAUDE.md` — Global context (what the system enforces)
2. `acm/ACM-STAGES-SPEC.md` — Stage overview
3. `acm/ACM-INTENT-SPEC.md` — Intent artifact definition
4. `acm/ACM-BRIEF-SPEC.md` — Brief artifact definition
5. `acm/BACKLOG.md` — Deferred items and open questions

**Architecture visuals:**
- `acm/prompts/architecture-visual-full-vision.md` — Full system prompt
- `acm/prompts/architecture-visual-base-layer.md` — Base layer prompt

---

## Open Questions

1. How detailed should stage specs be? (Minimal viable vs comprehensive)
2. Should each stage have its own CLAUDE.md rules file?
3. What skills/prompts does Discover stage need?
4. How does intent.md get validated for "crystal clear" criteria?

---

## Session Context

This handoff was created at the end of a session focused on building the ACM Base Layer. The human (Jess) is starting new projects to test ACM and will iterate on stage definitions based on real usage.

**Approach preference:** Minimal, iterative, Goldilocks — don't over-engineer, build what's needed.
