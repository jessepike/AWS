---
type: "tasks"
description: "Atomic task list for external-review skill + MCP server"
version: "1.0.0"
created: "2026-01-31"
updated: "2026-01-31"
backlog_ref: "B14"
plan_ref: "docs/plan.md"
---

# Tasks: External Review Skill + MCP Server

## Phase A: Server Foundation

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| A1 | Scaffold project structure + venv + requirements.txt | done | Directories exist: `skills/external-review/server/providers/`, `__init__.py` files, `requirements.txt` created, venv created, requirements installed | — | pip |
| A2 | Implement config loading + tests | done | Loads `config.yaml` + `~/.claude/models.yaml`, partial load on bad entries, clear errors. Tests: valid config, missing file, partial invalid, env var resolution | A1 | pyyaml, pytest |
| A3 | Implement path validation + tests | done | Allows paths under project root + home, rejects others, returns clear error. Tests: allowed paths, rejected paths, edge cases | A1 | pytest |
| A4 | Implement provider base class | done | Abstract `BaseProvider` with `review()` + `health_check()`, `ReviewResponse` dataclass | A1 | — |
| A5 | Implement MCP server entry point + `list_models` tool | done | `external_review_server.py` with FastMCP init, stdio transport, `list_models` registered and returning model info from loaded config | A2, A4 | mcp SDK |

## Phase B: Providers

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| B1 | Implement OpenAI-compatible provider + tests | done | Sends chat completion, handles response, timeout, retry with backoff, extra_params. Tests (mocked HTTP): success, timeout, rate limit retry, auth error, extra params | A4 | httpx, pytest-asyncio |
| B2 | Implement Google provider + tests | done | Sends generateContent, handles response, timeout, retry with backoff, extra_params. Tests (mocked HTTP): success, timeout, rate limit retry, auth error, extra params | A4 | httpx, pytest-asyncio |

## Phase C: Review Tool

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| C1 | Implement `review` tool + tests | done | Parallel calls via asyncio.gather, reads artifact from disk, aggregated response. Partial failures handled (one model error doesn't fail all). Tests: all succeed, one fails, all fail, timeout, artifact not found | B1, B2, A3, A5 | mcp SDK, pytest-asyncio |

## Phase D: Skill

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| D1 | Create `config.yaml` | done | Stage→prompt mapping, default models, cycle rules, execution settings | A1 | — |
| D2 | Create `SKILL.md` | done | Stage detection, prompt resolution, model resolution, confirmation flow, Ralph Loop invocation | D1, C1 | ralph-loop |

## Phase E: Integration Testing

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| E1 | MCP server startup + integration test | done | Server starts via stdio, responds to `list_models`, `review` with mocked providers returns expected aggregated format, shuts down cleanly | A5, C1 | mcp SDK, pytest-asyncio |

## Phase F: Registration & Docs

| ID | Task | Status | Acceptance Criteria | Depends | Capability |
|----|------|--------|---------------------|---------|------------|
| F1 | Register in `.mcp.json` | done | Server entry added, Claude Code can discover tools | E1 | — |
| F2 | End-to-end verification | done | `/external-review` skill visible, `list_models` returns configured models | F1, D2 | — |
