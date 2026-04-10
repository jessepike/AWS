---
type: "specification"
description: "Defines content and purpose of Global CLAUDE.md"
version: "1.2.0"
updated: "2026-02-04"
scope: "adf"
lifecycle: "reference"
location: "adf/ADF-GLOBAL-CLAUDE-MD-SPEC.md"
---

# ADF Global CLAUDE.md Specification

## Purpose

Define what belongs in `~/.claude/CLAUDE.md` — the universal guardrails layer that applies to ALL projects regardless of domain, complexity, or stack.

## Design Principles

**Irreducible:** Only include what is truly universal. If it depends on project type, complexity, or domain — it belongs at project level.

**Guardrails, not workflow:** Global defines safety constraints and communication norms. It does NOT prescribe how to plan, structure tasks, or organize work.

**Minimal:** Small enough to fit comfortably in context without crowding out project-specific guidance. Target: <50 lines.

## Content Categories

### 1. Safety Constraints

Non-negotiable rules that prevent harm across all contexts.

| Constraint | Rationale |
|------------|-----------|
| Never commit secrets, credentials, or API keys | Security — prevents accidental exposure |
| Confirm before destructive operations | Safety — delete/drop/overwrite are irreversible |
| Ask when uncertain rather than assume | Quality — prevents compounding errors |

### 2. Commit Hygiene

Universal standards for version control integrity.

| Standard | Rationale |
|----------|-----------|
| Atomic commits (one logical change) | Traceability — clean history, easy rollback |
| Conventional format: `type(scope): description` | Consistency — readable, parseable commit log |
| Verify before commit (lint, test, build) | Quality — don't commit broken code |

### 3. Communication Style

Norms for agent-human interaction.

| Norm | Rationale |
|------|-----------|
| Concise — bullets over paragraphs | Efficiency — respect human attention |
| Flag blockers immediately | Transparency — don't spin wheels silently |
| State assumptions explicitly | Clarity — enables correction before execution |

### 4. Rules Protection

Governance boundary between human and agent authority.

| Rule | Rationale |
|------|-----------|
| Never modify `.claude/rules/` without explicit human approval | Governance — rules are human-controlled |

### 5. Agent Session Protocol

Universal session discipline that applies to ALL projects.

```markdown
## Agent Session Protocol

1. **Session Start:** Read status.md first. Understand current state, last session, next steps.
2. **Session End:** Update status.md before closing — log what was done, update next steps. Do not ask, just update.
```

| Behavior | Rationale |
|----------|-----------|
| Read status.md at session start | Continuity — pick up where last session left off |
| Update status.md at session end | Handoff — next session knows current state |
| "Do not ask, just update" | Efficiency — session discipline is non-negotiable |

**This belongs in global, not project.** Every project needs session discipline. Project CLAUDE.md should NOT duplicate this section.

### 6. Available Resources (optional)

Cross-project resources agents should know about. Keep to a brief list — not detailed usage instructions.

| Resource | Rationale |
|----------|-----------|
| MCP servers (e.g., ADF MCP server) | Agents need to know what tools are available for on-demand queries |
| Plugins (e.g., adf-env) | Agents need to know what environment management is available |
| Shared repos (e.g., capabilities registry) | Agents need to know where to look up capabilities |

**Keep this lean.** List the resource and its purpose in one line. Detailed usage belongs in skills or documentation, not global context.

## Relationship to `.claude/rules/`

Global CLAUDE.md and project-level `.claude/rules/` serve complementary purposes:

| Layer | Scope | Purpose | Precedence |
|-------|-------|---------|------------|
| Global `<constraints>` | All projects | Universal safety constraints | Baseline |
| `.claude/rules/` | Per-project | Project-specific hard constraints | Extends global |
| `CLAUDE.md` | Per-project | Context, norms, working guidance | Defers to rules |

Global constraints (in `<constraints>` block) apply everywhere. Project rules in `.claude/rules/` add project-specific policy on top. `CLAUDE.md` provides context and norms that help Claude work effectively but are not enforcement boundaries.

If a rule in `.claude/rules/` conflicts with guidance in `CLAUDE.md`, the rule wins.

## Out of Scope (Project-Level)

The following belong in `.claude/CLAUDE.md` or `.claude/rules/`, NOT global:

- Plan/phase/task structure
- Stage model (Discover → Design → Setup → Develop → Deliver)
- Stack-specific conventions
- Domain terminology
- Architecture patterns
- Token budgets
- Artifact templates
- Testing conventions

## File Structure

Global CLAUDE.md uses a flat structure with XML constraint tags for priority signaling:

```markdown
# Global Context

<constraints>
[Non-negotiable safety rules — highest priority]
</constraints>

## [Category]
[Standards and norms — regular priority]
```

The `<constraints>` block signals to the agent that these rules are inviolable.

## Governance

| Aspect | Rule |
|--------|------|
| Who modifies | Human only |
| Change process | Manual edit |
| Version tracking | Optional (low churn expected) |
| Location | `~/.claude/CLAUDE.md` |

## Validation Checklist

Before deploying Global CLAUDE.md:

- [ ] All content is truly universal (applies to any project)
- [ ] No project-specific or domain-specific guidance
- [ ] No workflow prescriptions (plans, phases, tasks)
- [ ] Under 50 lines
- [ ] Constraints block contains only safety-critical items

## References

- Source: TIER1_KIT_SPEC.md (extracted and simplified)
- Parent: ADF-GLOBAL-PRIMITIVES-v0.1.md
