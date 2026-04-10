---
type: "backlog"
description: "Deferred items and future work for ACM"
version: "1.0.0"
updated: "2026-01-25"
lifecycle: "reference"
location: "acm/BACKLOG.md"
---

# ACM Backlog

Deferred items, open questions, and future work.

---

## Deferred: Build After Real Usage

| Item | Description | Build When |
|------|-------------|------------|
| **acm-validate** | Skill to validate artifacts against specs (frontmatter, progressive disclosure, token optimization, minimal viable context) | After real projects reveal what actually drifts |
| **acm-prune** | Skill to clean CLAUDE.md dynamic sections, process inbox, manage archive | After experiencing context bloat |
| **Frontmatter lint tooling** | Automated validation of frontmatter fields | After manual validation patterns stabilize |
| **Token budget monitoring** | Tool to check CLAUDE.md stays under 300 lines | When context bloat becomes a problem |

---

## Stage Development (Next Priority)

| Stage | Status | Notes |
|-------|--------|-------|
| **Discover** | Spec exists (overview only) | Needs: detailed inputs/outputs, skills, prompts, exit criteria |
| **Design** | Spec exists (overview only) | Needs: detailed approach decisions framework |
| **Develop** | Spec exists (overview only) | Needs: execution patterns, checkpoint guidance |
| **Deliver** | Mentioned only | Needs: full spec, handoff criteria |

---

## Open Questions

### Intent & Brief

- [ ] What makes intent.md "crystal clear"? Define validation criteria.
- [ ] Should intent.md have formal change control process?
- [ ] Does brief.md need version history or just version bump?

### Stage Model

- [ ] Should each stage have its own `.claude/rules/` file?
- [ ] How do stages signal completion to each other?
- [ ] What triggers stage transitions — human or agent?

### Cross-Cutting Concerns

- [ ] Where do constraints, opportunities, risks, rewards live?
- [ ] Are these captured in brief.md or separate artifacts?
- [ ] How do they evolve through stages?

### Validation

- [ ] What does "validates against artifact spec" actually check?
- [ ] Should validation be blocking or advisory?
- [ ] How to handle validation failures gracefully?

### Context Management

- [ ] How often should CLAUDE.md dynamic sections be pruned?
- [ ] What's the inbox SLA (how long can items sit)?
- [ ] When does archive get cleaned?

---

## Ideas to Explore

| Idea | Description | Priority |
|------|-------------|----------|
| **Stage-specific prompts** | Pre-built prompts for concept review, feasibility check, etc. | Medium |
| **Project manifest** | Single file listing all project artifacts and their status | Low |
| **Intent drift detection** | Automated check if work is drifting from intent | Low |
| **Cross-project learnings** | Way to promote learnings from one project to Meta Layer | Future |
| **Multi-agent coordination** | How multiple agents share context on same project | Future |

---

## Documentation Debt

- [ ] ACM-GLOBAL-PRIMITIVES-v0.1.md — needs alignment with what we built
- [ ] AGENT-INSTRUCTIONS.md — may need refinement after real agent usage
- [ ] README.md — update if package structure changes

---

## Testing Needed

- [ ] Run init-project.sh on fresh system
- [ ] Test all three project types (software, artifact, workflow)
- [ ] Verify global CLAUDE.md loads correctly in Claude Code
- [ ] Test agent orientation flow with real project

---

## Completed (Reference)

| Item | Completed | Notes |
|------|-----------|-------|
| Global CLAUDE.md spec | 2026-01-25 | v2.0.1 |
| Global CLAUDE.md file | 2026-01-25 | ~65 lines |
| Project types spec | 2026-01-25 | Software/Artifact/Workflow |
| Folder structure spec | 2026-01-25 | Base + type-specific |
| Intent spec | 2026-01-25 | North Star definition |
| Brief spec | 2026-01-25 | Scope/criteria definition |
| Context artifact spec | 2026-01-25 | Frontmatter, lifecycle |
| init-project.sh | 2026-01-25 | Interactive scaffolding |
| Architecture prompts | 2026-01-25 | Full vision + base layer |
