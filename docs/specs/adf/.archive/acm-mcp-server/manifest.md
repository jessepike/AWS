---
type: "manifest"
project: "ACM MCP Server"
version: "1.0"
status: "approved"
created: "2026-01-31"
design_ref: "docs/design.md"
---

# Manifest: ACM MCP Server

## Runtime

| Requirement | Version | Notes |
|-------------|---------|-------|
| Node.js | >= 18 | Required by MCP SDK |
| npm | latest | Package manager |

## Production Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `@modelcontextprotocol/sdk` | latest | MCP protocol — McpServer, StdioServerTransport, tool registration |
| `zod` | ^3.x | Schema validation (required by SDK's registerTool) |
| `gray-matter` | ^4.x | YAML frontmatter parsing for ACM markdown files |

## Dev Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `typescript` | ^5.x | TypeScript compiler |
| `@types/node` | >= 18 | Node.js type definitions |
| `vitest` | ^3.x | Test runner — fast, native ESM + TypeScript support |

## External Services

None. Zero network dependencies at runtime.

## Build

- `tsc` — TypeScript compilation to `build/`
- No bundler needed (local stdio server)
