---
type: "capabilities"
description: "Agent infrastructure for external-review skill + MCP server"
version: "1.0.0"
created: "2026-01-31"
updated: "2026-01-31"
backlog_ref: "B14"
design_ref: "docs/design.md"
---

# Capabilities: External Review Skill + MCP Server

## MCP Servers

| Server | Purpose | Source |
|--------|---------|--------|
| acm (existing) | Prompt retrieval via `get_review_prompt()` | Project .mcp.json — already configured |
| external-review (this project) | External model API calls — `list_models`, `review` | Will register in project .mcp.json |

## Plugins

| Plugin | Purpose | Source |
|--------|---------|--------|
| ralph-loop | Review cycle orchestration — skill invokes Ralph Loop with resolved prompt | registry: `active/plugin/@anthropic/ralph-loop` — already installed |

## Skills

| Skill | Purpose | Source |
|-------|---------|--------|
| mcp-builder | Reference for MCP server patterns | registry: `active/skill/@anthropic/mcp-builder` |

## CLIs & Tools

| Tool | Purpose | Install |
|------|---------|---------|
| pip | Python package management | Bundled with Python |
| python3 | MCP server runtime | System or brew |

## Sub-agents

None required. Single-agent build.

## Testing Capabilities

| Capability | Purpose |
|------------|---------|
| pytest | Unit + integration tests for server and providers |
| pytest-asyncio | Async test support for provider calls |
