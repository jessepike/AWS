---
adr: 001
title: AWS Governance Activation
date: 2026-04-09
status: accepted
owner: Forge
version_bump: 0.0.0 → 1.0.0
---

# ADR-001: AWS Governance Activation

## Context

The Agentic Work System (AWS) has a mature architectural design —
layers-and-rings model, component registry, maturity model, communication
protocols — but the operationalization layer is sparse. Standards directory
is empty. No decision log. No version control on standards. No propagation
mechanism. No single agent with write authority. The result is organic,
bursty evolution that drifts across the portfolio: each project implements
its own variant of the "right" structure, and the author (Jesse) loses
calibration between sessions.

The symptoms:
- 16 duplicate ADF spec files in `tools/ai-dev/` that drifted from
  canonical specs in `_shared/adf/`
- Project CLAUDE.md files duplicate global CLAUDE.md content, creating
  drift on every global update
- Exec agents split between `pike-agents/plugins/` (capabilities) and
  `agent-exec/` (context) despite a decision to merge
- Forge agent itself not registered in the capabilities-registry
- `_shared/agentic-work-system/docs/standards/` directory exists but empty
- Old projects (e.g. pike-acm) can't use current tooling because they
  predate current standards
- No baseline for "what good looks like"

## Decision

1. **AWS is Jesse's personal operating system.** It governs ALL daily work
   across every project. It is NOT a subset or mirror of AGF (the
   commercial client framework at `~/code/clients/risk/AGF/`). AWS borrows
   conceptual patterns from AGF but implements them at solo-dev velocity.

2. **Forge is the exclusive write-authority agent for AWS components.**
   Enforced via soft rule in global CLAUDE.md. No hard hooks in Day 1.
   AWS components include: standards, specs, decisions, entries in the
   capabilities-registry, skill source in `ai-dev/skills/`, agent
   definitions in `pike-agents/`, global CLAUDE.md governance sections,
   session lifecycle skills, and MCP/hook configs related to AWS
   governance.

3. **AWS directory is renamed to `_shared/aws/`** with a symlink at the
   old `_shared/agentic-work-system/` path for reversibility. Shortname
   matches colloquial usage.

4. **ADF specs fold into `_shared/aws/docs/specs/adf/`.** ADF is pure
   documentation; it belongs inside the governance home. Symlink at old
   `_shared/adf/` for safety.

5. **Other `_shared/` components stay as peers.** Knowledge Base, Memory,
   Capabilities Registry, Krypton, Pike-agents, Link Triage, Work
   Management, Nerve Center are runtime components with their own state
   and lifecycles. AWS references them via its component registry but
   does not contain them.

6. **ai-dev is a project governed by AWS, not part of AWS.** Future
   rename to `aws-workbench` is backlogged.

7. **First-class artifacts every project must have:** intent.md, status.md,
   lessons.md, BACKLOG.md, CLAUDE.md (project-specific shell only),
   docs/active/. Codified in `project-layout.yaml` standard.

8. **Project CLAUDE.md contains ONLY project-specific content.** Zero
   duplication of global CLAUDE.md. Global rules are loaded every turn;
   duplicating them into project files is the primary drift source.

9. **Four initial standards:** project-layout.yaml, claude-md.yaml,
   artifact-frontmatter.yaml, session-lifecycle.yaml. Living in
   `_shared/aws/docs/standards/`. YAML format for machine enforcement.

10. **Versioned and logged.** AWS gets a VERSION file (start at 1.0.0)
    and a CHANGELOG.md. Every change to standards bumps version and
    creates an ADR.

## Consequences

**Positive:**
- Single source of truth for governance
- Drift detectable via scheduled audit (Day 2 work)
- Client template can be extracted from AWS once proven
- Forge has clear scope and authority
- Global CLAUDE.md stops duplicating itself into projects

**Negative / risks:**
- Path rename risk — mitigated by symlinks
- Soft gate is not enforced — relies on Forge honoring the rule (future:
  hard hook)
- Existing projects (pike-acm, etc.) still non-conformant until
  `/project-doctor` built on Day 2
- Backlogged items (pike-agents merge, ai-dev rename) remain tech debt

## Related decisions

- **Deferred:** Pike-agents / agent-exec merge (dedicated session)
- **Deferred:** ai-dev → aws-workbench rename (dedicated session)
- **Day 2:** `/project-doctor` skill, `workflow-change-detector` skill,
  baseline-audit.sh, nightly launchd job

## References

- Sprint handoff: `tools/ai-dev/docs/active/aws-governance-sprint-handoff.md`
- AWS architecture: `_shared/aws/docs/architecture.md`
- AWS component registry: `_shared/aws/docs/component-registry.md`
- AGF intent (for contrast): `~/code/clients/risk/AGF/intent.md`
