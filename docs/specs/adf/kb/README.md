---
type: "documentation"
description: "Knowledge base index — research findings and learnings for reuse"
version: "1.0.0"
created: "2026-01-27"
updated: "2026-01-27"
scope: "adf"
lifecycle: "reference"
---

# ADF Knowledge Base

Research findings, validated learnings, and reusable knowledge captured during ACM development.

---

## Purpose

Capture research and learnings so they can be:
- Referenced by agents working on ADF projects
- Reused across different contexts
- Evolved as new findings emerge

---

## Entries

| Entry | Summary | Created |
|-------|---------|---------|
| [DOCUMENT-BREAKOUT-THRESHOLD](DOCUMENT-BREAKOUT-THRESHOLD.md) | 500-line threshold for splitting documents — based on LLM context efficiency, cognitive load, and industry standards | 2026-01-27 |
| [REVIEW-CYCLE-GUIDANCE](REVIEW-CYCLE-GUIDANCE.md) | Stop at diminishing returns — typically 2 internal + 1-2 external cycles for most projects | 2026-01-28 |

---

## Entry Format

Each KB entry should have:

```yaml
---
type: "knowledge-base"
description: "[Brief description]"
version: "1.0.0"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
scope: "adf"
lifecycle: "reference"
tags: ["relevant", "tags"]
---
```

Structure:
1. **Summary** — Key finding in 1-2 sentences
2. **The Number/Finding** — Concrete, actionable result
3. **Rationale** — Why this is the answer (research, data, reasoning)
4. **Application** — How to use this in practice
5. **Sources** — Where the research came from

---

## When to Create KB Entries

- Research that answers a question definitively
- Validated learnings from real usage
- Decisions with non-obvious rationale
- Patterns that apply across multiple contexts

**Not KB entries:**
- Stage specs (those are specifications)
- Project-specific decisions (those go in project decision logs)
- Opinions without validation

---

## Future Work

Known improvements identified but not yet implemented:

| Item | Description | Priority |
|------|-------------|----------|
| External review automation | Python script calling LLM APIs to automate external review loop | Medium |
| File transfer script | Need a clean way to copy ACM files (specs, prompts) from shared repo to working project. Shell script as Design stage output? | Medium |
| Review command friction | Ralph Loop commands require manual path construction — high friction. Need: (1) project-level config storing paths (ACM dir, project dir, registry), (2) wrapper script or command that reads config and builds the command automatically, (3) possibly stage-aware — knows which review prompt to use based on current stage in status.md | High |

## Recently Addressed (2026-01-29)

| Item | Resolution |
|------|------------|
| Agent skips planning gate in Develop | B1: Harden start-develop prompt with explicit STOP. Spec already has HARD GATE — prompt doesn't enforce it. |
| Poor capability self-assessment | B2: Extract capabilities-registry as peer repo. B10: Wire develop spec Phase 2 to INVENTORY.md. |
| No context clearing between phases | B3: Agent-driven `/clear` + re-read artifacts + confirm transition summary. |
| Review diminishing returns | B4: Simple scoring — Critical/High/Low tags. Stop when zero C+H. Min 2, max 10 cycles. |
| Prompt path friction | B5-B7: Audit prompts for stale paths, emit ready-to-copy commands. |
| Commands vs Skills terminology | B8: Claude Code 2.1.3 folded commands into skills. Update all specs. |
| Environment layer undefined | Created ADF-ARCHITECTURE-SPEC.md (formerly ADF-ENVIRONMENT-SPEC.md) — six primitives (orchestration, capabilities, knowledge, memory, maintenance, validation). Two layers (project + environment). |
| Knowledge vs Memory distinction | Knowledge = curated/evergreen/read-heavy. Memory = raw/temporal/write-heavy. Separate repos. |
| Registry organization | By capability name, not vendor. Three types: skills, tools, agents. Tags for queryability. |

## Recently Addressed (2026-01-28)

| Item | Resolution |
|------|------------|
| Individual clarification questions | Added explicit instruction in 4b: "Walk through EACH open item individually" with wrong/right examples |
| Self-validation before proceeding | Added 4d Self-Validation Checkpoint with explicit self-check questions |
| Planning vs execution gate | Added HARD GATE after Phase 3, split phases into Planning (1-3) and Execution (4-6) workflows |
| Capabilities.md wrong abstraction | ADF-DEVELOP-SPEC v1.1.0: Restructured with required sections (MCP Servers, Skills, Sub-agents, CLIs, Testing) |
| Missing registry query | Added registry query step to Capability Assessment phase in ADF-DEVELOP-SPEC |
| Task status tracking | Added Status column requirement to tasks.md format in ADF-DEVELOP-SPEC |
| Artifact sequence unclear | Made explicit: Manifest → Capabilities → Plan → Tasks (ADF-DEVELOP-SPEC) |
| One-off artifact correction | Created develop-artifact-correction-prompt.md for fixing existing artifacts |
