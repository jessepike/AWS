---
type: "plan"
description: "Implementation plan for external-review skill + MCP server"
version: "1.1.0"
status: "internal-review-complete"
created: "2026-01-31"
updated: "2026-01-31"
backlog_ref: "B14"
design_ref: "docs/design.md"
---

# Plan: External Review Skill + MCP Server

## Overview

Build a Python MCP server that calls external LLMs for Phase 2 reviews, plus a SKILL.md that orchestrates invocation via Ralph Loop. Two tools (`list_models`, `review`), two provider types (openai_compat, google), parallel execution.

## Phases

### Phase A: Server Foundation

Scaffold the MCP server, config loading, and provider base class.

- Project structure + venv under `skills/external-review/server/`
- Config loading (`config.yaml` + `~/.claude/models.yaml`) + tests
- Provider base class with abstract interface
- Path validation (restrict to project root + home) + tests
- MCP server entry point (`external_review_server.py` with FastMCP, stdio)
- `list_models` tool implementation

### Phase B: Providers

Implement the two provider types with tests (TDD).

- OpenAI-compatible provider + mocked HTTP tests
- Google Generative AI provider + mocked HTTP tests
- Error handling, timeout, retry with exponential backoff
- Extra params pass-through

### Phase C: Review Tool

Implement the `review` tool with parallel execution and tests (TDD).

- Parallel model calls via `asyncio.gather`
- Aggregated response format
- Per-model timeout and error handling
- Partial results on failure (don't fail all if one model errors)
- Tests with mocked providers

### Phase D: Skill

Create SKILL.md that wires everything together.

- Stage/artifact/prompt resolution logic
- Confirmation flow
- Ralph Loop invocation pattern
- `config.yaml` with stage→prompt mapping

### Phase E: Integration Testing

End-to-end verification (unit tests are co-located with implementation in Phases A-C per TDD).

- MCP server startup/shutdown smoke test
- Full integration test with mocked providers

### Phase F: Registration & Docs

Wire into the project and document.

- Register in project `.mcp.json`
- `requirements.txt`
- Verify end-to-end with Claude Code

## Testing Strategy

- **TDD** for providers and config loading — write tests first
- **Mock HTTP** for provider tests (no real API calls in CI)
- **Real server startup** test to verify MCP registration works
- pytest + pytest-asyncio

## Risk Areas

| Risk | Mitigation |
|------|------------|
| Provider API differences | Abstract base class + per-provider tests |
| MCP SDK API changes | Pin version in requirements.txt |
| models.yaml missing/invalid | Partial load with clear error messages |

## Decision Log

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | Path validation: project root + home | MVP scope, protect against obvious mistakes |
| D2 | Invalid models.yaml: partial load | One bad key shouldn't block working models |
| D3 | No cost metadata in list_models | YAGNI — user already chose models |
| D4 | Project .mcp.json registration | ACM-scoped tool, follows existing pattern |
| D5 | venv in server/ | Isolate dependencies |
| D6 | Official `mcp` Python SDK | Standard ecosystem approach |

## Issue Log

| # | Issue | Source | Severity | Status | Resolution |
|---|-------|--------|----------|--------|------------|
| 1 | Tests split into separate tasks/phases, breaking TDD strategy | Ralph-Develop | High | Resolved | Co-located tests with implementation tasks in A2, A3, B1, B2, C1 |
| 2 | No task for venv creation despite Decision D5 | Ralph-Develop | High | Resolved | Added to A1 (scaffold + venv) |
| 3 | Phase A description missing venv setup | Ralph-Develop | High | Resolved | Added venv to Phase A description |
| 4 | No task for MCP server entry point (external_review_server.py init, stdio, tool registration) | Ralph-Develop | Critical | Resolved | Added to A5 (MCP server entry point + list_models) |
| 5 | Missing `__init__.py` in scaffold task | Ralph-Develop | Low | Open | — |
| 6 | requirements.txt in Phase F but needed in Phase A for venv install | Ralph-Develop | High | Resolved | Moved to A1 (scaffold + venv + requirements.txt), removed F1 |
| 7 | Phase 1 internal review complete | Ralph-Develop | — | Complete | 3 cycles: 1 Critical, 4 High resolved |
