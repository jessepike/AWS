---
type: "reference"
description: "Reference guide for agents working on ACM-managed projects"
version: "2.0.0"
updated: "2026-01-27"
lifecycle: "reference"
location: "acm/AGENT-INSTRUCTIONS.md"
---

# ACM Agent Instructions

Reference guide for agents working on projects managed with ACM (Agentic Context Management).

> **Note:** This is a reference document for detailed guidance. The essential Session Protocol is in each project's CLAUDE.md file, which is auto-loaded.

---

## Session Protocol (Critical)

Every agent session follows this protocol:

### Session Start

1. **CLAUDE.md is auto-loaded** — This is the entry point
2. **Read status.md** — Understand current state, last session, next steps
3. **Read intent.md** — Remind yourself of the North Star
4. **Check current stage** — Discover, Design, Develop, or Deliver
5. **Pick up where last session left off**

### Session End

1. **Update status.md** — Log what was done, update next steps
2. **Note any blockers or pending decisions**
3. **Ensure work is saved/committed**

**This is mandatory.** Failing to update status.md breaks continuity for the next session.

---

## Context Loading

CLAUDE.md contains a Context Map that tells you what to load:

```markdown
## Context Map

| File | Load When | Purpose |
|------|-----------|---------|
| docs/intent.md | Always | North Star |
| docs/status.md | Always | Session state |
| docs/discover-brief.md | Discover, Design | Project contract |
```

- **Always** = Load every session
- **Stage name** = Load when in that stage
- **On demand** = Reference when needed

---

## Stage Awareness

### Identify Current Stage

Check CLAUDE.md or status.md for current stage:

| Stage | Signs | Your Focus |
|-------|-------|------------|
| **Discover** | Brief incomplete, exploring | Clarify intent, define scope, run review loops |
| **Design** | Brief complete, approach undefined | Make architecture/tech decisions |
| **Develop** | Approach decided, building | Execute work correctly |
| **Deliver** | Work complete, not yet deployed | Make it accessible, verify criteria |

### Stage-Specific Behavior

**Discover:**
- Help clarify and refine intent
- Draft and iterate on Brief
- Process review feedback
- Challenge assumptions constructively

**Design:**
- Make approach decisions explicit
- Document tradeoffs in decision log
- Identify dependencies and risks

**Develop:**
- Execute tasks according to plan
- Follow established patterns
- Update status.md frequently

**Deliver:**
- Verify against success criteria
- Ensure accessibility
- Document for handoff

---

## Project Types

Check CLAUDE.md for classification:

| Type | Indicators | Focus |
|------|------------|-------|
| **App** | `src/`, `tests/`, deployed software | Code, architecture, deployment |
| **Artifact** | `output/`, `assets/` | Content, format, audience |
| **Workflow** | `workflows/`, `scripts/` | Integration, triggers, data flow |

---

## Core Artifacts

### Always Maintain (Every Session)

| Artifact | Update When |
|----------|-------------|
| `status.md` | Every session end |
| `CLAUDE.md` | Stage changes, structure changes |

### Stage-Critical

| Artifact | Update When |
|----------|-------------|
| `intent.md` | Rarely (only if direction changes) |
| `discover-brief.md` | During Discover, then stable |
| Project `README.md` | Major milestones |

---

## Working Principles

### Always

- **Align to intent** — Every action should serve the North Star
- **Stay in scope** — Check Brief boundaries before expanding
- **Update status** — Don't leave the next session blind
- **Ask when uncertain** — Don't assume; clarify

### Never

- Modify intent.md without explicit human approval
- Skip status.md update at session end
- Expand scope without checking Brief
- Make destructive changes without confirmation

---

## Global Constraints

From `~/.claude/CLAUDE.md` (always apply):

- Never commit secrets, credentials, or API keys
- Never modify .claude/rules/ without explicit human approval
- Confirm before destructive operations
- Ask when uncertain rather than assume

---

## Validation Checklist

When reviewing a project for ACM compliance:

### Structure
- [ ] `.claude/CLAUDE.md` exists with Context Map
- [ ] `docs/intent.md` exists and is clear
- [ ] `docs/discover-brief.md` exists
- [ ] `docs/status.md` exists and is current
- [ ] Type-specific folders present

### Session Protocol
- [ ] status.md updated at last session end
- [ ] Next steps are actionable
- [ ] No stale information

---

## References

- ACM-STAGES-SPEC.md — Stage workflow details
- ACM-BRIEF-SPEC.md — Brief structure and requirements
- ACM-STATUS-SPEC.md — Status tracking
- ACM-PROJECT-TYPES-SPEC.md — Type classification
- ACM-TAXONOMY.md — Terminology and decisions
