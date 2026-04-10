---
type: "brief"
project: "External Review Skill + MCP Server"
version: "0.1"
status: "discover-complete"
created: "2026-01-31"
updated: "2026-01-31"
intent_ref: "../docs/intent.md"
backlog_ref: "B14"
---

# Brief: External Review Skill + MCP Server

## Classification

- **Type:** App
- **Scale:** personal
- **Scope:** mvp
- **Complexity:** standalone

## Summary

Build an MCP server and companion skill that automates Phase 2 external reviews by calling external LLM APIs (Kimi K2, Gemini, DeepSeek) within Ralph Loop cycles. Claude Code orchestrates and synthesizes feedback. This eliminates the manual copy-paste friction that discourages external review usage.

## Scope

### In Scope

- Python MCP server with provider abstraction (OpenAI-compatible, Google, Moonshot)
- Parallel external model calls with aggregated responses
- `/external-review` skill that wires into Ralph Loop
- Cross-reviewer synthesis (dedup, consensus weighting, severity classification)
- User-level API key configuration (`~/.claude/models.yaml`)
- Skill-level config (`config.yaml`) for stage→prompt mapping and defaults

### Out of Scope

- ACM process knowledge serving (ACM MCP server handles this)
- Internal review orchestration (Ralph Loop plugin handles Phase 1)
- Prompt authoring (prompts already exist in `acm/prompts/`)

## Success Criteria

- [ ] User runs `/external-review` and gets a fully automated Phase 2 review cycle
- [ ] Multiple models called in parallel with aggregated results
- [ ] Synthesis applies ACM-REVIEW-SPEC rules (severity, complexity, action matrix)
- [ ] Auto-fix for Low/Medium complexity issues; High complexity flagged for user
- [ ] Configuration confirmation before execution
- [ ] Graceful handling of API failures (retry, timeout, partial results)

## Constraints

- ACM-REVIEW-SPEC v1.2.0 governs cycle rules, severity, stop conditions
- API keys never in git — user-level config only
- External review server is separate bounded context from ACM MCP server (different risk profile, different language)
- Skill lives at `acm/skills/external-review/` per ACM-ARCHITECTURE-SPEC v1.2.0

## Decisions

| Decision | Chosen | Rationale |
|----------|--------|-----------|
| Separate from ACM MCP server | Yes | Different bounded context — API keys, network calls, cost vs read-only local files |
| Python for MCP server | Yes | Provider SDKs are Python-native, async HTTP |
| Skill + MCP server as one project | Yes | Skill is the interface, server is the engine — tightly coupled |
| Consumer of ACM MCP server prompts | Yes | Uses `get_review_prompt()` for prompt retrieval |
