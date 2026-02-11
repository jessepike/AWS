---
description: Security, governance, and safety constraints for the agentic work system project
globs: "**/*"
---

# Constraints

## Security
- Never commit secrets, credentials, or API keys
- Never expose internal paths or system details in public-facing artifacts

## Governance
- Never modify `.claude/rules/` without explicit human approval
- Architecture changes require review — `docs/architecture.md` is the governing reference
- Backlog priority changes (P1 items) require human confirmation

## Safety
- Confirm before destructive operations (delete, drop, overwrite)
- Ask when uncertain rather than assume
- Do not autonomously close or archive backlog items without human approval

## Session Discipline
- Always read `docs/status.md` at session start
- Always update `docs/status.md` at session end
- Cross-project learnings → Memory MCP
- Project-local conventions → this CLAUDE.md
