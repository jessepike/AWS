---
type: "manifest"
description: "Software dependencies for external-review skill + MCP server"
version: "1.0.0"
created: "2026-01-31"
updated: "2026-01-31"
backlog_ref: "B14"
design_ref: "docs/design.md"
---

# Manifest: External Review Skill + MCP Server

## Runtime

| Dependency | Version | Purpose |
|------------|---------|---------|
| Python | 3.11+ | MCP server runtime |

## Python Packages

| Package | Version | Purpose |
|---------|---------|---------|
| `mcp` | latest | Official MCP Python SDK — stdio transport, tool registration |
| `httpx` | latest | Async HTTP client — provider API calls |
| `pyyaml` | latest | YAML parsing — models.yaml, config.yaml |

## Dev/Test

| Package | Version | Purpose |
|---------|---------|---------|
| `pytest` | latest | Test runner |
| `pytest-asyncio` | latest | Async test support |

## External Services

| Service | Purpose | Auth |
|---------|---------|------|
| OpenAI-compatible APIs (Kimi K2, DeepSeek) | External review models | API key via `~/.claude/models.yaml` |
| Google Generative AI API (Gemini) | External review model | API key via `~/.claude/models.yaml` |
